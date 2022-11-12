import 'dart:collection';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'src/models/chart_data.dart';
import 'src/models/chart_config.dart';

void main() {
  runApp(const DerivChartApp());
}

/// The start of the application.
class DerivChartApp extends StatelessWidget {
  /// Initialize
  const DerivChartApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData.light(),
        home: const _DerivChartWebAdapter(),
      );
}

class _DerivChartWebAdapter extends StatefulWidget {
  const _DerivChartWebAdapter({Key? key}) : super(key: key);

  @override
  State<_DerivChartWebAdapter> createState() => _DerivChartWebAdapterState();
}

class _DerivChartWebAdapterState extends State<_DerivChartWebAdapter> {
  _DerivChartWebAdapterState() {
    chartConfigModel = ChartConfigModel(_controller);
  }

  final ChartController _controller = ChartController();

  final ChartDataModel chartDataModel = ChartDataModel();
  late final ChartConfigModel chartConfigModel;

  @override
  void initState() {
    super.initState();
    html.window.addEventListener('message', listen, false);
  }

  void listen(html.Event event) {
    final LinkedHashMap<dynamic, dynamic> data =
        (event as html.MessageEvent).data;
    final String messageType = data['type'];
    final dynamic payload = data['payload'];

    chartConfigModel.update(messageType, payload);
    chartDataModel.update(messageType, payload);
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
          providers: <ChangeNotifierProvider<dynamic>>[
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
                      builder: (BuildContext context,
                              ChartConfigModel chartConfigModel,
                              ChartDataModel chartDataModel,
                              Widget? child) =>
                          DerivChart(
                              mainSeries: chartConfigModel.style ==
                                          ChartStyle.candles &&
                                      chartDataModel.ticks is List<Candle>
                                  ? CandleSeries(
                                      chartDataModel.ticks as List<Candle>)
                                  : LineSeries(
                                      chartDataModel.ticks,
                                      style: const LineStyle(hasArea: true),
                                    ) as DataSeries<Tick>,
                              annotations: chartDataModel.ticks.length > 4
                                  ? <ChartAnnotation<ChartObject>>[
                                      if (chartConfigModel.slBarrier != null)
                                        chartConfigModel.slBarrier
                                            as ChartAnnotation<ChartObject>,
                                      if (chartConfigModel.tpBarrier != null)
                                        chartConfigModel.tpBarrier
                                            as ChartAnnotation<ChartObject>,
                                      TickIndicator(
                                        chartDataModel.ticks.last,
                                        style: HorizontalBarrierStyle(
                                          color: Colors.redAccent,
                                          labelShape: LabelShape.pentagon,
                                          hasBlinkingDot: true,
                                          hasArrow: false,
                                          shadeType: chartConfigModel.shadeType,
                                        ),
                                        visibility: HorizontalBarrierVisibility
                                            .keepBarrierLabelVisible,
                                      ),
                                    ]
                                  : null,
                              granularity: chartConfigModel.granularity ?? 1000,
                              controller: _controller,
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
