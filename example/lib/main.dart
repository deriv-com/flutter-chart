import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter_deriv_api/api/api_initializer.dart';
import 'package:flutter_deriv_api/api/common/models/candle_model.dart';
import 'package:flutter_deriv_api/api/common/tick/ohlc.dart';
import 'package:flutter_deriv_api/api/common/tick/tick.dart' as api_tick;
import 'package:flutter_deriv_api/api/common/tick/tick_base.dart';
import 'package:flutter_deriv_api/api/common/tick/tick_history.dart';
import 'package:flutter_deriv_api/api/common/tick/tick_history_subscription.dart';
import 'package:flutter_deriv_api/basic_api/generated/api.dart';
import 'package:flutter_deriv_api/services/connection/api_manager/base_api.dart';
import 'package:flutter_deriv_api/services/connection/api_manager/connection_information.dart';
import 'package:flutter_deriv_api/services/dependency_injector/injector.dart';
import 'package:vibration/vibration.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays(<SystemUiOverlay>[]);
  runApp(MyApp());
}

/// App widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FullscreenChart(),
      );
}

/// Chart screen widget
class FullscreenChart extends StatefulWidget {
  /// Creates the chart screen
  const FullscreenChart({
    Key key,
  }) : super(key: key);

  @override
  _FullscreenChartState createState() => _FullscreenChartState();
}

class _FullscreenChartState extends State<FullscreenChart> {
  List<Candle> candles = <Candle>[];
  ChartStyle style = ChartStyle.line;
  int granularity = 0;
  TickBase _currentTick;

  // We keep track of the candles start epoch to not make more than one API call to get a history
  int _startEpoch;

  @override
  void initState() {
    super.initState();
    _connectToAPI();
  }

  Future<void> _connectToAPI() async {
    APIInitializer().initialize();
    await Injector.getInjector().get<BaseAPI>().connect(
          ConnectionInformation(
            appId: '1089',
            brand: 'binary',
            endpoint: 'frontend.binaryws.com',
          ),
        );

    await _initTickStream();
  }

  Future<void> _initTickStream() async {
    try {
      final TickHistorySubscription historySubscription =
          await _getHistoryAndSubscribe();

      _startEpoch = candles.first.epoch;

      historySubscription.tickStream.listen((TickBase tickBase) {
        if (tickBase != null) {
          _currentTick = tickBase;

          if (tickBase is api_tick.Tick) {
            _onNewTick(tickBase.epoch.millisecondsSinceEpoch, tickBase.quote);
          }

          if (tickBase is OHLC) {
            final Candle newCandle = Candle(
              epoch: tickBase.openTime.millisecondsSinceEpoch,
              high: tickBase.high,
              low: tickBase.low,
              open: tickBase.open,
              close: tickBase.close,
            );
            _onNewCandle(newCandle);
          }
        }
      });

      setState(() {});
    } on Exception catch (e) {
      dev.log(e.toString(), error: e);
    }
  }

  Future<TickHistorySubscription> _getHistoryAndSubscribe() async {
    try {
      final TickHistorySubscription history =
          await TickHistory.fetchTicksAndSubscribe(
        TicksHistoryRequest(
          ticksHistory: 'R_50',
          end: 'latest',
          count: 50,
          style: granularity == 0 ? 'ticks' : 'candles',
          granularity: granularity > 0 ? granularity : null,
        ),
      );

      candles.clear();
      candles = _getCandlesFromResponse(history.tickHistory);

      return history;
    } on Exception catch (e) {
      dev.log(e.toString(), error: e);
      return null;
    }
  }

  void _onNewTick(int epoch, double quote) {
    setState(() {
      candles = candles + <Candle>[Candle.tick(epoch: epoch, quote: quote)];
    });
  }

  void _onNewCandle(Candle newCandle) {
    final List<Candle> previousCandles =
        candles.isNotEmpty && candles.last.epoch == newCandle.epoch
            ? candles.sublist(0, candles.length - 1)
            : candles;

    setState(() {
      // Don't modify candles in place, otherwise Chart's didUpdateWidget won't see the difference.
      candles = previousCandles + <Candle>[newCandle];
    });
  }

  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xFF0E0E0E),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                _buildChartTypeButton(),
                _buildIntervalSelector(),
              ],
            ),
            Expanded(
              child: ClipRect(
                child: Chart(
                  candles: candles,
                  pipSize: 4,
                  style: style,
                  onCrosshairAppeared: () => Vibration.vibrate(duration: 50),
                  onLoadHistory: (int fromEpoch, int toEpoch, int count) =>
                      _loadHistory(fromEpoch, toEpoch, count),
                ),
              ),
            ),
          ],
        ),
      );

  Future<void> _loadHistory(int fromEpoch, int toEpoch, int count) async {
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

      final List<Candle> loadedCandles = _getCandlesFromResponse(moreData)
        ..removeLast();

      // Unlikely to happen, just to ensure we don't have two candles with the same epoch
      while (loadedCandles.isNotEmpty &&
          loadedCandles.last.epoch >= candles.first.epoch) {
        loadedCandles.removeLast();
      }

      candles.insertAll(0, loadedCandles);
    }
  }

  IconButton _buildChartTypeButton() => IconButton(
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

  Widget _buildIntervalSelector() => Theme(
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
              .map<DropdownMenuItem<int>>(
                  (int granularity) => DropdownMenuItem<int>(
                        value: granularity,
                        child: Text('${_granularityLabel(granularity)}'),
                      ))
              .toList(),
          onChanged: _onIntervalSelected,
        ),
      );

  Future<void> _onIntervalSelected(int value) async {
    try {
      await _currentTick?.unsubscribe();
    } on Exception catch (e) {
      dev.log(e.toString(), error: e);
    }
    granularity = value;
    await _initTickStream();
  }

  String _granularityLabel(int granularity) {
    switch (granularity) {
      case 0:
        return '1 tick';
      case 60:
        return '1 min';
      case 120:
        return '2 min';
      case 180:
        return '3 min';
      case 300:
        return '5 min';
      case 600:
        return '10 min';
      case 900:
        return '15 min';
      case 1800:
        return '30 min';
      case 3600:
        return '1 hour';
      case 7200:
        return '2 hours';
      case 14400:
        return '4 hours';
      case 28800:
        return '8 hours';
      case 86400:
        return '1 day';
      default:
        return '???';
    }
  }

  List<Candle> _getCandlesFromResponse(TickHistory tickHistory) {
    List<Candle> candles = <Candle>[];
    if (tickHistory.history != null) {
      final int count = tickHistory.history.prices.length;
      for (int i = 0; i < count; i++) {
        candles.add(Candle.tick(
          epoch: tickHistory.history.times[i].millisecondsSinceEpoch,
          quote: tickHistory.history.prices[i],
        ));
      }
    }

    if (tickHistory.candles != null) {
      candles = tickHistory.candles
          .map<Candle>((CandleModel ohlc) => Candle(
                epoch: ohlc.epoch.millisecondsSinceEpoch,
                high: ohlc.high,
                low: ohlc.low,
                open: ohlc.open,
                close: ohlc.close,
              ))
          .toList();
    }
    return candles;
  }
}
