import 'dart:collection';
import 'dart:convert';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void main() {
  runApp(const DerivChartApp());
}

class Message {
  late String type;
  dynamic payload;

  Message(this.type, this.payload);

  Message.fromMap(LinkedHashMap<dynamic, dynamic> map) {
    type = map["type"];
    payload = map["payload"];
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'payload': payload,
      };
}

class ChartDataModel extends ChangeNotifier {
  List<Tick> ticks = <Tick>[];
  bool waitingForHistory = false;

  void listen(Message message) {
    switch (message.type) {
      case 'TICKS_HISTORY':
        _onTickHistory(message, false);
        break;
      case 'PREPEND_TICKS_HISTORY':
        _onTickHistory(message, true);
        break;
      case 'TICK':
        Tick tick = _parseTick(message.payload);
        _onNewTick(tick);
        break;
      case 'CANDLE':
        Candle candle = _parseCandle(message.payload);
        _onNewCandle(candle);
        break;
      case 'CLEAR_TICKS':
        _onClearTicks();
        break;
    }
  }

  Tick _parseTick(dynamic item) {
    return Tick(
      epoch: DateTime.parse('${item['Date']}Z').millisecondsSinceEpoch,
      quote: item['Close'],
    );
  }

  Candle _parseCandle(dynamic item) {
    return Candle(
        epoch: DateTime.parse('${item['Date']}Z').millisecondsSinceEpoch,
        high: item['High'],
        low: item['Low'],
        open: item['Open'],
        close: item['Close']);
  }

  void _onNewTick(Tick tick) {
    ticks = ticks + <Tick>[tick];
    notifyListeners();
  }

  void _onNewCandle(Candle newCandle) {
    final List<Tick> previousCandles =
        ticks.isNotEmpty && ticks.last.epoch == newCandle.epoch
            ? ticks.sublist(0, ticks.length - 1)
            : ticks;

    // Don't modify candles in place, otherwise Chart's didUpdateWidget won't
    // see the difference.
    ticks = previousCandles + <Candle>[newCandle];
    notifyListeners();
  }

  void _onTickHistory(Message message, bool append) {
    var payload = message.payload as List;

    var newTicks = payload.map((item) {
      return item['Open'] != null ? _parseCandle(item) : _parseTick(item);
    }).toList();

    if (payload.first['Open'] != null) {
      newTicks = payload.map((item) {
        return _parseCandle(item);
      }).toList();
    } else {
      newTicks = payload.map((item) {
        return _parseTick(item);
      }).toList();
    }

    if (append) {
      while (newTicks.isNotEmpty && newTicks.last.epoch >= ticks.first.epoch) {
        newTicks.removeLast();
      }

      ticks.insertAll(0, newTicks);
    } else {
      ticks = newTicks;
    }

    if (append) {
      waitingForHistory = false;
    }

    notifyListeners();
  }

  void _onClearTicks() {
    ticks = [];
    notifyListeners();
  }

  void loadHistory(int count) async {
    waitingForHistory = true;

    Map loadHistoryRequest = {"count": count, "end": ticks.first.epoch ~/ 1000};

    var loadHistoryMessage =
        Message('LOAD_HISTORY', jsonEncode(loadHistoryRequest));

    html.window.parent!.postMessage(loadHistoryMessage.toJson(), '*');
    notifyListeners();
  }
}

class ChartConfigModel extends ChangeNotifier {
  ChartStyle style = ChartStyle.line;
  int? granularity;
  ChartTheme? theme;
  late final ChartController controller;

  ChartConfigModel(this.controller);

  void listen(Message message) {
    switch (message.type) {
      case 'UPDATE_THEME':
        _updateTheme(message);
        break;
      case 'NEW_CHART':
        _onNewChart(message);
        break;
      case 'SCALE_CHART':
        _onScale(message);
        break;
      case 'UPDATE_CHART_STYLE':
        _updateChartStyle(message);
        break;
    }
  }

  void _updateChartStyle(Message message) {
    style = message.payload == ChartStyle.candles.name
        ? ChartStyle.candles
        : ChartStyle.line;
    notifyListeners();
  }

  void _updateTheme(Message message) {
    theme = message.payload == 'dark'
        ? ChartDefaultDarkTheme()
        : ChartDefaultLightTheme();
    notifyListeners();
  }

  void _onNewChart(Message message) {
    print(message.payload['granularity']);
    if (message.payload['granularity'] != null) {
      int _granularity = message.payload['granularity'];
      granularity = _granularity == 0 ? 1 * 1000 : _granularity * 1000;
      notifyListeners();
    }
  }

  void _onScale(Message message) {
    double scale = message.payload;
    controller.scale(scale);
  }
}

class DerivChartApp extends StatelessWidget {
  const DerivChartApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      home: const DerivChartWebAdapter(),
    );
  }
}

class DerivChartWebAdapter extends StatefulWidget {
  const DerivChartWebAdapter({Key? key}) : super(key: key);

  @override
  State<DerivChartWebAdapter> createState() => _DerivChartWebAdapterState();
}

class _DerivChartWebAdapterState extends State<DerivChartWebAdapter> {
  final ChartController _controller = ChartController();

  final ChartDataModel chartDataModel = ChartDataModel();
  late final ChartConfigModel chartConfigModel;

  _DerivChartWebAdapterState() {
    chartConfigModel = ChartConfigModel(_controller);
  }

  @override
  void initState() {
    super.initState();
    html.window.addEventListener('message', listen, false);
  }

  void listen(html.Event event) {
    var data = (event as html.MessageEvent).data;
    var message = Message.fromMap(data);

    chartConfigModel.listen(message);
    chartDataModel.listen(message);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<ChartConfigModel>.value(
              value: chartConfigModel),
          ChangeNotifierProvider<ChartDataModel>.value(value: chartDataModel)
        ],
        child: Scaffold(
          body: Center(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Consumer2<ChartConfigModel, ChartDataModel>(
                    builder: (context, chartConfigModel, chartDataModel,
                            child) =>
                        DerivChart(
                            mainSeries:
                                chartConfigModel.style == ChartStyle.candles &&
                                        chartDataModel.ticks is List<Candle>
                                    ? CandleSeries(
                                        chartDataModel.ticks as List<Candle>)
                                    : LineSeries(
                                        chartDataModel.ticks,
                                        style: const LineStyle(hasArea: true),
                                      ) as DataSeries<Tick>,
                            // markerSeries: MarkerSeries(
                            //   _markers,
                            //   activeMarker: _activeMarker,
                            // ),
                            annotations: chartDataModel.ticks.length > 4
                                ? <ChartAnnotation<ChartObject>>[
                                    // ..._sampleBarriers,
                                    // if (_sl && _slBarrier != null)
                                    //   _slBarrier as ChartAnnotation<ChartObject>,
                                    // if (_tp && _tpBarrier != null)
                                    //   _tpBarrier as ChartAnnotation<ChartObject>,
                                    TickIndicator(
                                      chartDataModel.ticks.last,
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
                            pipSize: 4,
                            granularity: chartConfigModel.granularity ?? 1000,
                            controller: _controller,
                            // isLive: (_symbol.isOpen) &&
                            //     (_connectionBloc.state
                            //         is connection_bloc.ConnectionConnectedState),
                            opacity: 1.0,
                            theme: chartConfigModel.theme,
                            // onCrosshairAppeared: () =>
                            //    Vibration.vibrate(duration: 50),
                            onVisibleAreaChanged:
                                (int leftEpoch, int rightEpoch) {
                              if (!chartDataModel.waitingForHistory &&
                                  chartDataModel.ticks.isNotEmpty &&
                                  leftEpoch <
                                      chartDataModel.ticks.first.epoch) {
                                chartDataModel.loadHistory(2500);
                              }
                            }),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
