import 'dart:async';
import 'dart:developer' as dev;

import 'package:deriv_chart/deriv_chart.dart';
import 'package:example/widgets/connection_status_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deriv_api/api/common/active_symbols/active_symbols.dart';
import 'package:flutter_deriv_api/api/common/tick/exceptions/tick_exception.dart';
import 'package:flutter_deriv_api/api/common/tick/ohlc.dart';
import 'package:flutter_deriv_api/api/common/tick/tick.dart' as api_tick;
import 'package:flutter_deriv_api/api/common/tick/tick_base.dart';
import 'package:flutter_deriv_api/api/common/tick/tick_history.dart';
import 'package:flutter_deriv_api/api/common/tick/tick_history_subscription.dart';
import 'package:flutter_deriv_api/basic_api/generated/api.dart';
import 'package:flutter_deriv_api/services/connection/api_manager/connection_information.dart';
import 'package:flutter_deriv_api/state/connection/connection_bloc.dart';
import 'package:vibration/vibration.dart';

import 'utils/misc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: FullscreenChart(),
        ),
      ),
    );
  }
}

class FullscreenChart extends StatefulWidget {
  const FullscreenChart({
    Key key,
  }) : super(key: key);

  @override
  _FullscreenChartState createState() => _FullscreenChartState();
}

class _FullscreenChartState extends State<FullscreenChart> {
  List<Candle> candles = [];
  ChartStyle style = ChartStyle.line;
  int granularity = 0;

  TickHistorySubscription _tickHistorySubscription;

  StreamSubscription _tickStreamSubscription;

  ConnectionBloc _connectionBloc;

  // We keep track of the candles start epoch to not make more than one API call to get a history
  int _startEpoch;

  Completer _requestCompleter;

  List<Market> _markets;

  Asset _symbol;

  @override
  void initState() {
    super.initState();
    _requestCompleter = Completer();
    _connectToAPI();
  }

  @override
  void dispose() {
    _tickStreamSubscription?.cancel();
    _connectionBloc?.close();
    super.dispose();
  }

  Future<void> _connectToAPI() async {
    _connectionBloc = ConnectionBloc(ConnectionInformation(
      appId: '1089',
      brand: 'binary',
      endpoint: 'frontend.binaryws.com',
    ))
      ..listen((connectionState) async {
        setState(() {});
        if (connectionState is Connected) {
          if (candles.isEmpty) {
            await _getActiveSymbols();
            _initTickStream();
          } else {
            _resumeTickStream();
          }
        }
      });
  }

  Future<void> _getActiveSymbols() async {
    final List<ActiveSymbol> activeSymbols =
        await ActiveSymbol.fetchActiveSymbols(const ActiveSymbolsRequest(
            activeSymbols: 'brief', productType: 'basic'));

    final ActiveSymbol firstOpenSymbol = activeSymbols
        .firstWhere((ActiveSymbol activeSymbol) => activeSymbol.exchangeIsOpen);

    _symbol = Asset(
      name: firstOpenSymbol.symbol,
      displayName: firstOpenSymbol.displayName,
    );

    final marketTitles = <String>{};

    final markets = <Market>[];

    for (final symbol in activeSymbols) {
      if (!marketTitles.contains(symbol.market)) {
        marketTitles.add(symbol.market);
        markets.add(
          Market.fromAssets(
            name: symbol.market,
            displayName: symbol.marketDisplayName,
            assets: activeSymbols
                .where((activeSymbol) => activeSymbol.market == symbol.market)
                .map<Asset>((activeSymbol) => Asset(
                      market: activeSymbol.market,
                      marketDisplayName: activeSymbol.marketDisplayName,
                      subMarket: activeSymbol.submarket,
                      name: activeSymbol.symbol,
                      displayName: activeSymbol.displayName,
                      subMarketDisplayName: activeSymbol.submarketDisplayName,
                    ))
                .toList(),
          ),
        );
      }
    }
    setState(() => _markets = markets);
  }

  void _resumeTickStream() async {
    try {
      _tickStreamSubscription?.cancel();

      _tickHistorySubscription = await TickHistory.fetchTicksAndSubscribe(
        TicksHistoryRequest(
          ticksHistory: _symbol.name,
          end: '${DateTime.now().millisecondsSinceEpoch ~/ 1000}',
          start: candles.last.epoch ~/ 1000,
          style: granularity == 0 ? 'ticks' : 'candles',
          granularity: granularity > 0 ? granularity : null,
        ),
      );

      final missedCandles =
          _getCandlesFromResponse(_tickHistorySubscription.tickHistory);

      if (candles.last.epoch == missedCandles.first.epoch) {
        candles.removeLast();
      }

      setState(() => candles.addAll(missedCandles));

      _tickStreamSubscription =
          _tickHistorySubscription.tickStream.listen(_handleTickStream);
    } on TickException catch (e) {
      dev.log(e.message, error: e);
    } finally {
      _completeRequest();
    }
  }

  void _initTickStream() async {
    try {
      _tickHistorySubscription = await TickHistory.fetchTicksAndSubscribe(
        TicksHistoryRequest(
          ticksHistory: _symbol.name,
          end: 'latest',
          count: 500,
          style: granularity == 0 ? 'ticks' : 'candles',
          granularity: granularity > 0 ? granularity : null,
        ),
      );

      setState(() {
        candles.clear();
        candles = _getCandlesFromResponse(_tickHistorySubscription.tickHistory);

        _startEpoch = candles.first.epoch;
      });

      _tickStreamSubscription =
          _tickHistorySubscription.tickStream.listen(_handleTickStream);
    } on TickException catch (e) {
      dev.log(e.message, error: e);
    } finally {
      _completeRequest();
    }
  }

  void _completeRequest() {
    if (!_requestCompleter.isCompleted) {
      _requestCompleter.complete(null);
    }
  }

  void _handleTickStream(TickBase newTick) {
    if (newTick != null) {
      if (newTick is api_tick.Tick) {
        _onNewTick(Candle.tick(
          epoch: newTick.epoch.millisecondsSinceEpoch,
          quote: newTick.quote,
        ));
      } else if (newTick is OHLC) {
        _onNewCandle(Candle(
          epoch: newTick.openTime.millisecondsSinceEpoch,
          high: newTick.high,
          low: newTick.low,
          open: newTick.open,
          close: newTick.close,
        ));
      }
    }
  }

  void _onNewTick(Candle newTick) {
    setState(() => candles = candles + [newTick]);
  }

  void _onNewCandle(Candle newCandle) {
    final previousCandles =
        candles.isNotEmpty && candles.last.epoch == newCandle.epoch
            ? candles.sublist(0, candles.length - 1)
            : candles;

    setState(() {
      // Don't modify candles in place, otherwise Chart's didUpdateWidget won't see the difference.
      candles = previousCandles + [newCandle];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(0xFF0E0E0E),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: _markets == null
                      ? SizedBox.shrink()
                      : _buildMarketSelectorButton(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _buildChartTypeButton(),
                      _buildIntervalSelector(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
                ClipRect(
                  child: Chart(
                    candles: candles,
                    pipSize:
                        _tickHistorySubscription?.tickHistory?.pipSize ?? 4,
                    style: style,
                    onCrosshairAppeared: () => Vibration.vibrate(duration: 50),
                    onLoadHistory: (fromEpoch, toEpoch, count) =>
                        _loadHistory(fromEpoch, toEpoch, count),
                  ),
                ),
                if (_connectionBloc != null &&
                    _connectionBloc.state is! Connected)
                  Align(
                    alignment: Alignment.center,
                    child: _buildConnectionStatus(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() => ConnectionStatusLabel(
        text: _connectionBloc.state is ConnectionError
            ? '${(_connectionBloc.state as ConnectionError).error}'
            : _connectionBloc.state is Disconnected
                ? 'Internet is down, trying to reconnect...'
                : 'Connecting...',
      );

  Widget _buildMarketSelectorButton() => MarketSelectorButton(
        asset: _symbol,
        onTap: () => showBottomSheet<void>(
          backgroundColor: Colors.transparent,
          context: context,
          builder: (BuildContext context) => MarketSelector(
            selectedItem: _symbol,
            markets: _markets,
            onAssetClicked: (asset, favoriteClicked) {
              if (!favoriteClicked) {
                Navigator.of(context).pop();
                _symbol = asset;
                _onIntervalSelected(granularity);
              }
            },
          ),
        ),
      );

  void _loadHistory(int fromEpoch, int toEpoch, int count) async {
    if (fromEpoch < _startEpoch) {
      // So we don't request for a history range more than once
      _startEpoch = fromEpoch;
      final TickHistory moreData = await TickHistory.fetchTickHistory(
        TicksHistoryRequest(
          ticksHistory: _symbol.name,
          end: '${toEpoch ~/ 1000}',
          count: count,
          style: granularity == 0 ? 'ticks' : 'candles',
          granularity: granularity > 0 ? granularity : null,
        ),
      );

      final List<Candle> loadedCandles = _getCandlesFromResponse(moreData);

      loadedCandles.removeLast();

      // Unlikely to happen, just to ensure we don't have two candles with the same epoch
      while (loadedCandles.isNotEmpty &&
          loadedCandles.last.epoch >= candles.first.epoch) {
        loadedCandles.removeLast();
      }

      candles.insertAll(0, loadedCandles);
    }
  }

  IconButton _buildChartTypeButton() {
    return IconButton(
      icon: Icon(
        style == ChartStyle.line ? Icons.show_chart : Icons.insert_chart,
        color: Colors.white,
      ),
      onPressed: () {
        Vibration.vibrate(duration: 50);
        setState(() {
          if (style == ChartStyle.candles) {
            style = ChartStyle.line;
          } else {
            style = ChartStyle.candles;
          }
        });
      },
    );
  }

  Widget _buildIntervalSelector() {
    return Theme(
      data: ThemeData.dark(),
      child: DropdownButton<int>(
        value: granularity,
        items: <int>[
          0,
          60,
          120,
          180,
          300,
          600,
          900,
          1800,
          3600,
          7200,
          14400,
          28800,
          86400,
        ]
            .map<DropdownMenuItem<int>>((granularity) => DropdownMenuItem<int>(
                  value: granularity,
                  child: Text('${getGranularityLabel(granularity)}'),
                ))
            .toList(),
        onChanged: _onIntervalSelected,
      ),
    );
  }

  Future<void> _onIntervalSelected(value) async {
    await _requestCompleter.future;
    _requestCompleter = Completer();

    try {
      await _tickHistorySubscription?.unsubscribe();
    } on Exception catch (e) {
      _completeRequest();
      dev.log(e.toString(), error: e);
    } finally {
      granularity = value;
      _initTickStream();
    }
  }

  List<Candle> _getCandlesFromResponse(TickHistory tickHistory) {
    List<Candle> candles = [];
    if (tickHistory.history != null) {
      final count = tickHistory.history.prices.length;
      for (var i = 0; i < count; i++) {
        candles.add(Candle.tick(
          epoch: tickHistory.history.times[i].millisecondsSinceEpoch,
          quote: tickHistory.history.prices[i],
        ));
      }
    }

    if (tickHistory.candles != null) {
      candles = tickHistory.candles.map<Candle>((ohlc) {
        return Candle(
          epoch: ohlc.epoch.millisecondsSinceEpoch,
          high: ohlc.high,
          low: ohlc.low,
          open: ohlc.open,
          close: ohlc.close,
        );
      }).toList();
    }
    return candles;
  }
}
