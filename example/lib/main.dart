import 'dart:async';

import 'package:example/widgets/connection_status_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter_deriv_api/api/common/tick/ohlc.dart';
import 'package:flutter_deriv_api/api/common/tick/tick.dart' as api_tick;
import 'package:flutter_deriv_api/api/common/tick/tick_base.dart';
import 'package:flutter_deriv_api/api/common/tick/tick_history.dart';
import 'package:flutter_deriv_api/basic_api/generated/api.dart';
import 'package:flutter_deriv_api/services/connection/api_manager/connection_information.dart';
import 'package:flutter_deriv_api/state/connection/connection_bloc.dart';
import 'package:flutter_deriv_api/services/connection/connection_service.dart';
import 'package:vibration/vibration.dart';

import 'utils/misc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: FullscreenChart(),
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
  TickBase _currentTick;

  StreamSubscription _tickSubscription;

  ConnectionBloc _connectionBloc;

  // We keep track of the candles start epoch to not make more than one API call to get a history
  int _startEpoch;

  Completer _requestCompleter;

  @override
  void initState() {
    super.initState();

    _requestCompleter = Completer();

    _connectToAPI();
  }

  @override
  void dispose() {
    _tickSubscription?.cancel();
    super.dispose();
  }

  Future<void> _connectToAPI() async {
    _connectionBloc = ConnectionBloc(ConnectionInformation(
      appId: '1089',
      brand: 'binary',
      endpoint: 'frontend.binaryws.com',
    ));

    _connectionBloc.listen((connectionState) async {
      setState(() {});
      if (connectionState is Connected) {
        if (candles.isEmpty) {
          _initTickStream();
        } else {
          _resumeTickStream();
        }
      }
    });
  }

  void _resumeTickStream() async {
    try {
      _tickSubscription?.cancel();

      final missedTicksHistory = await TickHistory.fetchTicksAndSubscribe(
        TicksHistoryRequest(
          ticksHistory: 'R_50',
          end: '${DateTime.now().millisecondsSinceEpoch ~/ 1000}',
          start: candles.last.epoch ~/ 1000,
          style: granularity == 0 ? 'ticks' : 'candles',
          granularity: granularity > 0 ? granularity : null,
        ),
      );

      final missedCandles =
          _getCandlesFromResponse(missedTicksHistory.tickHistory);

      if (candles.last.epoch == missedCandles.first.epoch) {
        candles.removeLast();
      }

      candles.addAll(missedCandles);

      _tickSubscription =
          missedTicksHistory.tickStream.listen(_handleTickStream);

      setState(() {});
    } on Exception catch (e) {
      print(e);
    }
  }

  void _initTickStream() async {
    try {
      final historySubscription = await TickHistory.fetchTicksAndSubscribe(
        TicksHistoryRequest(
          ticksHistory: 'R_50',
          end: 'latest',
          count: 500,
          style: granularity == 0 ? 'ticks' : 'candles',
          granularity: granularity > 0 ? granularity : null,
        ),
      );

      candles.clear();
      candles = _getCandlesFromResponse(historySubscription.tickHistory);

      _startEpoch = candles.first.epoch;

      _tickSubscription =
          historySubscription.tickStream.listen(_handleTickStream);

      setState(() {});
    } on Exception catch (e) {
      print(e);
    } finally {
      _completeRequest();
    }
  }

  void _completeRequest() {
    if (!_requestCompleter.isCompleted) {
      _requestCompleter.complete(null);
    }
  }

  void _handleTickStream(TickBase tickBase) {
    if (tickBase != null) {
      _currentTick = tickBase;

      if (tickBase is api_tick.Tick) {
        _onNewTick(tickBase.epoch.millisecondsSinceEpoch, tickBase.quote);
      }

      if (tickBase is OHLC) {
        final newCandle = Candle(
          epoch: tickBase.openTime.millisecondsSinceEpoch,
          high: tickBase.high,
          low: tickBase.low,
          open: tickBase.open,
          close: tickBase.close,
        );
        _onNewCandle(newCandle);
      }
    }
  }

  void _onNewTick(int epoch, double quote) {
    setState(() {
      candles = candles + [Candle.tick(epoch: epoch, quote: quote)];
    });
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
          Row(
            children: <Widget>[
              _buildChartTypeButton(),
              _buildIntervalSelector(),
              IconButton(
                icon: Icon(Icons.print),
                onPressed: () async {
                  _onIntervalSelected(120);
                },
              ),
              IconButton(
                icon: Icon(Icons.event),
                onPressed: () async {
                  _onIntervalSelected(0);
                },
              ),
            ],
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
                ClipRect(
                  child: Chart(
                    candles: candles,
                    pipSize: 4,
                    style: style,
                    onLoadHistory: (fromEpoch, toEpoch, count) =>
                        _onLoadHistory(fromEpoch, toEpoch, count),
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

  void _onLoadHistory(int fromEpoch, int toEpoch, int count) async {
    if (fromEpoch < _startEpoch) {
      // So we don't request for a history range more than once
      _startEpoch = fromEpoch;
      final TickHistory moreData = await TickHistory.fetchTickHistory(
        TicksHistoryRequest(
          ticksHistory: 'R_50',
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
                  child: Text('${granularityLabel(granularity)}'),
                ))
            .toList(),
        onChanged: _onIntervalSelected,
      ),
    );
  }

  void _onIntervalSelected(value) async {
    if (_requestCompleter.isCompleted) {
      _requestCompleter = Completer();
      try {
        await _currentTick?.unsubscribe();
        granularity = value;
        _initTickStream();
      } on Exception catch (e) {
        _completeRequest();
        print(e);
      }
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
