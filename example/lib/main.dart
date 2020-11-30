import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:deriv_chart/deriv_chart.dart';
import 'package:example/utils/market_change_reminder.dart';
import 'package:example/widgets/connection_status_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deriv_api/api/common/active_symbols/active_symbols.dart';
import 'package:flutter_deriv_api/api/common/server_time/server_time.dart';
import 'package:flutter_deriv_api/api/common/tick/exceptions/tick_exception.dart';
import 'package:flutter_deriv_api/api/common/tick/ohlc.dart';
import 'package:flutter_deriv_api/api/common/tick/tick.dart' as api_tick;
import 'package:flutter_deriv_api/api/common/tick/tick_base.dart';
import 'package:flutter_deriv_api/api/common/tick/tick_history.dart';
import 'package:flutter_deriv_api/api/common/tick/tick_history_subscription.dart';
import 'package:flutter_deriv_api/api/common/trading/trading_times.dart';
import 'package:flutter_deriv_api/basic_api/generated/api.dart';
import 'package:flutter_deriv_api/services/connection/api_manager/connection_information.dart';
import 'package:flutter_deriv_api/state/connection/connection_bloc.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:example/generated/l10n.dart';

import 'utils/misc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        ChartLocalization.delegate,
        ExampleLocalization.delegate,
      ],
      supportedLocales: ExampleLocalization.delegate.supportedLocales,
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
  List<Tick> ticks = <Tick>[];
  ChartStyle style = ChartStyle.line;
  int granularity = 0;

  List<Barrier> _sampleBarriers = <Barrier>[];
  HorizontalBarrier _slBarrier, _tpBarrier;
  bool _sl = false, _tp = false;

  TickHistorySubscription _tickHistorySubscription;

  StreamSubscription _tickStreamSubscription;

  ConnectionBloc _connectionBloc;

  bool _waitingForHistory = false;

  MarketChangeReminder _marketsChangeReminder;

  // Is used to make sure we make only one request to the API at a time. We will not make a new call until the prev call has completed.
  Completer _requestCompleter;

  List<Market> _markets;
  List<Marker> _markers = [];
  ActiveMarker _activeMarker;

  List<ActiveSymbol> _activeSymbols;

  Asset _symbol;

  ChartController _controller = ChartController();
  PersistentBottomSheetController _bottomSheetController;

  @override
  void initState() {
    super.initState();
    _requestCompleter = Completer<dynamic>();
    _connectToAPI();
  }

  @override
  void dispose() {
    _tickStreamSubscription?.cancel();
    _connectionBloc?.close();
    _bottomSheetController?.close();
    super.dispose();
  }

  Future<void> _connectToAPI() async {
    _connectionBloc = ConnectionBloc(ConnectionInformation(
      appId: '1089',
      brand: 'binary',
      endpoint: 'blue.binaryws.com',
    ))
      ..listen((connectionState) async {
        if (connectionState is! Connected) {
          // Calling this since we show some status labels when NOT connected.
          setState(() {});
          return;
        }

        if (ticks.isEmpty) {
          await _getActiveSymbols();

          _requestCompleter.complete();
          _onIntervalSelected(0);
        } else {
          _initTickStream(
            TicksHistoryRequest(
              ticksHistory: _symbol.name,
              adjustStartTime: 1,
              end: '${DateTime.now().millisecondsSinceEpoch ~/ 1000}',
              start: ticks.last.epoch ~/ 1000,
              style: granularity == 0 ? 'ticks' : 'candles',
              granularity: granularity > 0 ? granularity : null,
            ),
            resume: true,
          );
        }

        await _setupMarketChangeReminder();
      });
  }

  Future<void> _setupMarketChangeReminder() async {
    _marketsChangeReminder?.reset();
    _marketsChangeReminder = MarketChangeReminder(
      () async => await TradingTimes.fetchTradingTimes(
        TradingTimesRequest(tradingTimes: 'today'),
      ),
      onCurrentTime: () async {
        final ServerTime serverTime = await ServerTime.fetchTime();
        return serverTime.time.toUtc();
      },
      onMarketsStatusChange: (Map<String, bool> statusChanges) {
        for (int i = 0; i < _activeSymbols.length; i++) {
          if (statusChanges[_activeSymbols[i].symbol] != null) {
            _activeSymbols[i] = _activeSymbols[i].copyWith(
              exchangeIsOpen: statusChanges[_activeSymbols[i].symbol],
            );
          }
        }

        _fillMarketSelectorList();

        if (statusChanges[_symbol.name] != null) {
          _symbol = _symbol.copyWith(isOpen: statusChanges[_symbol.name]);

          // Request for tick stream if symbol is changing from closed to open.
          if (statusChanges[_symbol.name]) {
            _onIntervalSelected(granularity);
          }
        }
      },
    );
  }

  Future<void> _getActiveSymbols() async {
    _activeSymbols = await ActiveSymbol.fetchActiveSymbols(
      const ActiveSymbolsRequest(activeSymbols: 'brief', productType: 'basic'),
    );

    final ActiveSymbol firstOpenSymbol = _activeSymbols
        .firstWhere((ActiveSymbol activeSymbol) => activeSymbol.exchangeIsOpen);

    _symbol = Asset(
      name: firstOpenSymbol.symbol,
      displayName: firstOpenSymbol.displayName,
      market: firstOpenSymbol.market,
      subMarket: firstOpenSymbol.submarket,
      isOpen: firstOpenSymbol.exchangeIsOpen,
    );

    _fillMarketSelectorList();
  }

  void _fillMarketSelectorList() {
    final marketTitles = <String>{};

    final markets = <Market>[];

    for (final symbol in _activeSymbols) {
      if (!marketTitles.contains(symbol.market)) {
        marketTitles.add(symbol.market);
        markets.add(
          Market.fromAssets(
            name: symbol.market,
            displayName: symbol.marketDisplayName,
            assets: _activeSymbols
                .where((activeSymbol) => activeSymbol.market == symbol.market)
                .map<Asset>((activeSymbol) => Asset(
                      market: activeSymbol.market,
                      marketDisplayName: activeSymbol.marketDisplayName,
                      subMarket: activeSymbol.submarket,
                      name: activeSymbol.symbol,
                      displayName: activeSymbol.displayName,
                      subMarketDisplayName: activeSymbol.submarketDisplayName,
                      isOpen: activeSymbol.exchangeIsOpen,
                    ))
                .toList(),
          ),
        );
      }
    }
    setState(() => _markets = markets);
    _bottomSheetController?.setState(() {});
  }

  void _initTickStream(
    TicksHistoryRequest request, {
    bool resume = false,
  }) async {
    try {
      await _tickStreamSubscription?.cancel();

      if (_symbol.isOpen) {
        _tickHistorySubscription =
            await TickHistory.fetchTicksAndSubscribe(request);

        final fetchedTicks =
            _getTicksFromResponse(_tickHistorySubscription.tickHistory);

        if (resume) {
          // TODO(ramin): Consider changing TicksHistoryRequest params to avoid overlapping ticks
          if (ticks.last.epoch == fetchedTicks.first.epoch) {
            ticks.removeLast();
          }

          setState(() => ticks.addAll(fetchedTicks));
        } else {
          _resetCandlesTo(fetchedTicks);
        }

        _tickStreamSubscription =
            _tickHistorySubscription.tickStream.listen(_handleTickStream);
      } else {
        _tickHistorySubscription = null;

        final historyCandles = _getTicksFromResponse(
          await TickHistory.fetchTickHistory(request),
        );

        _resetCandlesTo(historyCandles);
      }

      _updateSampleSLAndTP();

      WidgetsBinding.instance.addPostFrameCallback(
        (Duration timeStamp) => _controller.scrollToLastTick(animate: false),
      );
    } on TickException catch (e) {
      dev.log(e.message, error: e);
    } finally {
      _completeRequest();
    }
  }

  void _resetCandlesTo(List<Tick> fetchedCandles) => setState(() {
        ticks.clear();
        _clearMarkers();
        _clearBarriers();
        ticks = fetchedCandles;
      });

  void _completeRequest() {
    if (!_requestCompleter.isCompleted) {
      _requestCompleter.complete(null);
    }
  }

  void _handleTickStream(TickBase newTick) {
    if (!_requestCompleter.isCompleted || newTick == null) {
      return;
    }

    if (newTick is api_tick.Tick) {
      _onNewTick(Tick(
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

  void _onNewTick(Tick newTick) {
    setState(() => ticks = ticks + [newTick]);
  }

  void _onNewCandle(Candle newCandle) {
    final List<Candle> previousCandles =
        ticks.isNotEmpty && ticks.last.epoch == newCandle.epoch
            ? ticks.sublist(0, ticks.length - 1)
            : ticks;

    setState(() {
      // Don't modify candles in place, otherwise Chart's didUpdateWidget won't see the difference.
      ticks = previousCandles + <Candle>[newCandle];
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
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: _markets == null
                      ? SizedBox.shrink()
                      : _buildMarketSelectorButton(),
                ),
                _buildChartTypeButton(),
                _buildIntervalSelector(),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
                ClipRect(
                  child: Chart(
                    mainSeries:
                        style == ChartStyle.candles && ticks is List<Candle>
                            ? CandleSeries(ticks)
                            : LineSeries(ticks),
                    secondarySeries: [
                      MASeries(
                        ticks,
                        style: LineStyle(
                          color: Colors.grey,
                          thickness: 0.5,
                          hasArea: false,
                        ),
                      ),
                    ],
                    markerSeries: MarkerSeries(
                      _markers,
                      activeMarker: _activeMarker,
                    ),
                    annotations: ticks.length > 4
                        ? <ChartAnnotation>[
                            ..._sampleBarriers,
                            if (_sl && _slBarrier != null) _slBarrier,
                            if (_tp && _tpBarrier != null) _tpBarrier,
                            TickIndicator(
                              ticks.last,
                              style: const HorizontalBarrierStyle(
                                color: Colors.redAccent,
                                labelShape: LabelShape.pentagon,
                                hasBlinkingDot: true,
                                hasArrow: false,
                              ),
                              visibility: HorizontalBarrierVisibility
                                  .keepBarrierLabelVisible,
                            ),
                          ]
                        : null,
                    pipSize:
                        _tickHistorySubscription?.tickHistory?.pipSize ?? 4,
                    granularity: granularity == 0
                        ? 2000 // average ms difference between ticks
                        : granularity * 1000,
                    controller: _controller,
                    isLive: (_symbol?.isOpen ?? false) &&
                        (_connectionBloc?.state is Connected ?? false),
                    opacity: _symbol?.isOpen ?? true ? 1.0 : 0.5,
                    onCrosshairAppeared: () => Vibration.vibrate(duration: 50),
                    onVisibleAreaChanged: (int leftEpoch, int rightEpoch) {
                      if (!_waitingForHistory &&
                          ticks.isNotEmpty &&
                          leftEpoch < ticks.first.epoch) {
                        _loadHistory(2000);
                      }
                    },
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
          SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RaisedButton(
                  color: Colors.green,
                  child: const Text('Up'),
                  onPressed: () => _addMarker(MarkerDirection.up),
                ),
                RaisedButton(
                  color: Colors.red,
                  child: const Text('Down'),
                  onPressed: () => _addMarker(MarkerDirection.down),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => setState(_clearMarkers),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FlatButton(
                  child: Text('V barrier'),
                  onPressed: () => setState(
                    () => _sampleBarriers.add(
                      VerticalBarrier.onTick(ticks.last,
                          title: 'V Barrier',
                          id: 'VBarrier${_sampleBarriers.length}',
                          longLine: math.Random().nextBool(),
                          style: VerticalBarrierStyle(
                            isDashed: math.Random().nextBool(),
                          )),
                    ),
                  ),
                ),
                FlatButton(
                  child: Text('H barrier'),
                  onPressed: () => setState(
                    () => _sampleBarriers.add(
                      HorizontalBarrier(
                        ticks.last.quote,
                        epoch:
                            math.Random().nextBool() ? ticks.last.epoch : null,
                        id: 'HBarrier${_sampleBarriers.length}',
                        longLine: math.Random().nextBool(),
                        visibility: HorizontalBarrierVisibility.normal,
                        style: HorizontalBarrierStyle(
                          color: Colors.grey,
                          labelShape: LabelShape.rectangle,
                          isDashed: math.Random().nextBool(),
                        ),
                      ),
                    ),
                  ),
                ),
                FlatButton(
                  child: Text('+ Both'),
                  onPressed: () => setState(() => _sampleBarriers.add(
                        CombinedBarrier(
                          ticks.last,
                          title: 'B Barrier',
                          id: 'CBarrier${_sampleBarriers.length}',
                          horizontalBarrierStyle: HorizontalBarrierStyle(
                            color: Colors.grey,
                            isDashed: true,
                          ),
                        ),
                      )),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => setState(() {
                    _clearBarriers();
                  }),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 64,
            child: Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    value: _sl,
                    onChanged: (bool sl) => setState(() => _sl = sl),
                    title: Text('Stop loss'),
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    value: _tp,
                    onChanged: (bool tp) => setState(() => _tp = tp),
                    title: Text('Take profit'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _addMarker(MarkerDirection direction) {
    final lastTick = ticks.last;
    final onTap = () {
      setState(() {
        _activeMarker = ActiveMarker(
          direction: direction,
          epoch: lastTick.epoch,
          quote: lastTick.quote,
          text: '0.00 USD',
          onTap: () {
            print('>>> tapped active marker');
          },
          onTapOutside: () {
            setState(() {
              _activeMarker = null;
            });
          },
        );
      });
    };
    setState(() {
      _markers.add(Marker(
        direction: direction,
        epoch: lastTick.epoch,
        quote: lastTick.quote,
        onTap: onTap,
      ));
    });
  }

  void _clearMarkers() {
    _markers.clear();
    _activeMarker = null;
  }

  void _clearBarriers() {
    _sampleBarriers.clear();
    _sl = false;
    _tp = false;
  }

  Widget _buildConnectionStatus() => ConnectionStatusLabel(
        text: _connectionBloc.state is ConnectionError
            ? '${(_connectionBloc.state as ConnectionError).error}'
            : _connectionBloc.state is Disconnected
                ? 'Connection lost, trying to reconnect...'
                : 'Connecting...',
      );

  Widget _buildMarketSelectorButton() => MarketSelectorButton(
        backgroundColor: Color.fromRGBO(21, 23, 23, 1),
        asset: _symbol,
        onTap: () {
          _bottomSheetController = showBottomSheet<void>(
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
          );
        },
      );

  void _loadHistory(int count) async {
    _waitingForHistory = true;

    final TickHistory moreData = await TickHistory.fetchTickHistory(
      TicksHistoryRequest(
        ticksHistory: _symbol.name,
        end: '${ticks.first.epoch ~/ 1000}',
        count: count,
        style: granularity == 0 ? 'ticks' : 'candles',
        granularity: granularity > 0 ? granularity : null,
      ),
    );

    final List<Tick> loadedCandles = _getTicksFromResponse(moreData);

    // Ensure we don't have two candles with the same epoch.
    while (loadedCandles.isNotEmpty &&
        loadedCandles.last.epoch >= ticks.first.epoch) {
      loadedCandles.removeLast();
    }

    setState(() {
      ticks.insertAll(0, loadedCandles);
    });

    _waitingForHistory = false;
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

  Future<void> _onIntervalSelected(int value) async {
    if (!_requestCompleter.isCompleted) {
      return;
    }

    _requestCompleter = Completer<dynamic>();

    setState(() => ticks.clear());

    try {
      await _tickHistorySubscription?.unsubscribe();
    } on Exception catch (e) {
      _completeRequest();
      dev.log(e.toString(), error: e);
    } finally {
      granularity = value;

      _initTickStream(TicksHistoryRequest(
        ticksHistory: _symbol.name,
        adjustStartTime: 1,
        end: 'latest',
        count: 10000,
        style: granularity == 0 ? 'ticks' : 'candles',
        granularity: granularity > 0 ? granularity : null,
      ));
    }
  }

  List<Tick> _getTicksFromResponse(TickHistory tickHistory) {
    List<Tick> candles = [];
    if (tickHistory.history != null) {
      final count = tickHistory.history.prices.length;
      for (var i = 0; i < count; i++) {
        candles.add(Tick(
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

  void _updateSampleSLAndTP() {
    final double ticksMin = ticks.map((Tick t) => t.quote).reduce(math.min);
    final double ticksMax = ticks.map((Tick t) => t.quote).reduce(math.max);

    _slBarrier = HorizontalBarrier(
      ticksMin,
      title: 'Stop loss',
      style: HorizontalBarrierStyle(
        color: const Color(0xFFCC2E3D),
        isDashed: false,
      ),
    );

    _tpBarrier = HorizontalBarrier(
      ticksMax,
      title: 'Take profit',
      style: HorizontalBarrierStyle(
        color: const Color(0xFF00A79E),
        isDashed: false,
      ),
    );
  }
}
