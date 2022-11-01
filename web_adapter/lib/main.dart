import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'src/models/chart-data.dart';
import 'src/models/chart-config.dart';
import 'src/models/message.dart';

void main() {
  runApp(const DerivChartApp());
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
                            annotations: chartDataModel.ticks.length > 4
                                ? <ChartAnnotation<ChartObject>>[
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
                            opacity: 1.0,
                            theme: chartConfigModel.theme,
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
