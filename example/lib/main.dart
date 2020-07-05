import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter_deriv_api/api/common/tick/ohlc.dart';
import 'package:flutter_deriv_api/api/common/tick/tick.dart' as api_tick;
import 'package:flutter_deriv_api/api/common/tick/tick_base.dart';
import 'package:flutter_deriv_api/api/common/tick/tick_history.dart';
import 'package:flutter_deriv_api/api/common/tick/tick_history_subscription.dart';
import 'package:flutter_deriv_api/basic_api/generated/api.dart';
import 'package:flutter_deriv_api/services/connection/api_manager/base_api.dart';
import 'package:flutter_deriv_api/services/connection/api_manager/connection_information.dart';
import 'package:flutter_deriv_api/services/dependency_injector/injector.dart';
import 'package:flutter_deriv_api/services/dependency_injector/module_container.dart';
import 'package:vibration/vibration.dart';

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

  @override
  void initState() {
    super.initState();
    _connectToAPI();
  }

  Future<void> _connectToAPI() async {
    ModuleContainer().initialize(Injector.getInjector());
    await Injector.getInjector().get<BaseAPI>().connect(ConnectionInformation(
        appId: '1089', brand: 'binary', endpoint: 'frontend.binaryws.com'));

    _initTickStream();
  }

  void _initTickStream() async {
    try {
      final historySubscription = await _getHistoryAndSubscribe();

      _leftMostEpoch = candles.first.epoch;

      historySubscription.tickStream.listen((tickBase) {
        if (tickBase != null) {
          _lastTick = tickBase;
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
      });

      setState(() {});
    } on Exception catch (e) {
      print(e);
    }
  }

  TickBase _lastTick;

  Future<TickHistorySubscription> _getHistoryAndSubscribe() async {
    try {
      final history = await TickHistory.fetchTicksAndSubscribe(
        TicksHistoryRequest(
          ticksHistory: 'R_50',
          end: 'latest',
          adjustStartTime: 1,
          start: DateTime.now()
                  .subtract(Duration(minutes: 3))
                  .millisecondsSinceEpoch ~/
              1000,
          style: granularity == 0 ? 'ticks' : 'candles',
          granularity: granularity > 0 ? granularity : null,
        ),
      );

      candles.clear();
      candles = _getCandlesFromResponse(history.tickHistory);

      return history;
    } on Exception catch (e) {
      print(e);
      return null;
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
      child: SizedBox.expand(
        child: Stack(
          children: <Widget>[
            Chart(
              candles: candles,
              pipSize: 4,
              style: style,
              onLoadMore: (startEpoch, endEpoch) {
                _loadMore(startEpoch, endEpoch);
              },
            ),
            _buildChartTypeButton(),
            Positioned(
              left: 60,
              child: _buildIntervalSelector(),
            )
          ],
        ),
      ),
    );
  }

  int _leftMostEpoch;

  void _loadMore(int startEpoch, int endEpoch) async {
    // So we don't request for a history range more than once
    if (startEpoch < _leftMostEpoch) {
      _leftMostEpoch = startEpoch;
      final TickHistory moreData = await TickHistory.fetchTickHistory(
        TicksHistoryRequest(
          ticksHistory: 'R_50',
          end: ((endEpoch) ~/ 1000).toString(),
          adjustStartTime: 1,
          start: startEpoch ~/ 1000,
          style: granularity == 0 ? 'ticks' : 'candles',
          granularity: granularity > 0 ? granularity : null,
        ),
      );

      final List<Candle> loadedCandles = _getCandlesFromResponse(moreData);

      while (loadedCandles.isNotEmpty &&
          loadedCandles.last.epoch >= candles.first.epoch) {
        print('removed last');
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
                  child: Text('${_granularityLabel(granularity)}'),
                ))
            .toList(),
        onChanged: _onIntervalSelected,
      ),
    );
  }

  void _onIntervalSelected(value) async {
    try {
      if (granularity == 0) {
        await _lastTick?.unsubscribe();
      } else {
        await _lastTick?.unsubscribe();
      }
    } on Exception catch (e) {
      print(e);
    }
    granularity = value;
    _initTickStream();
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
