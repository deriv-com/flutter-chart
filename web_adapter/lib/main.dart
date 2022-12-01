import 'dart:collection';
import 'dart:convert';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_adapter/src/interop/js_interop.dart';
import 'package:web_adapter/src/models/message.dart';
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
    chartConfigModel = ChartConfigModel(_controller, chartDataModel);
    initInterOp(listen, chartConfigModel);
  }

  final ChartController _controller = ChartController();

  final ChartDataModel chartDataModel = ChartDataModel();
  late final ChartConfigModel chartConfigModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => onLoad());
  }

  void onLoad() {
    final Message loadHistoryMessage = Message('ON_LOAD', '');
    JsInterop.postMessage(loadHistoryMessage.toJson());
  }

  void listen(String dataString) {
    final dynamic data = json.decode(dataString);
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
                            ? CandleSeries(chartDataModel.ticks as List<Candle>)
                            : LineSeries(
                                chartDataModel.ticks,
                                style: const LineStyle(hasArea: true),
                              ) as DataSeries<Tick>,
                        annotations: chartDataModel.ticks.length > 4
                            ? <Barrier>[
                                if (chartConfigModel.slBarrier != null)
                                  chartConfigModel.slBarrier as Barrier,
                                if (chartConfigModel.tpBarrier != null)
                                  chartConfigModel.tpBarrier as Barrier,
                                if (chartConfigModel.isLive)
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
                        onVisibleAreaChanged: (int leftEpoch, int rightEpoch) {
                          if (!chartDataModel.waitingForHistory &&
                              chartDataModel.ticks.isNotEmpty &&
                              leftEpoch < chartDataModel.ticks.first.epoch) {
                            chartDataModel.loadHistory(2500);
                          }
                          JsInterop.onVisibleAreaChanged(leftEpoch, rightEpoch);
                        },
                        onQuoteAreaChanged:
                            (double topQuote, double bottomQuote) {
                          JsInterop.onQuoteAreaChanged(topQuote, bottomQuote);
                        },
                        barriers: <Barrier>[
                          if (chartConfigModel.draggableBarrier != null)
                            chartConfigModel.draggableBarrier as Barrier,
                          if (chartConfigModel.purchaseBarrier != null)
                            chartConfigModel.purchaseBarrier as Barrier
                        ],
                        markerSeries: MarkerSeries(
                          SplayTreeSet<Marker>(),
                          markerGroupList: chartConfigModel.markerGroupList,
                          markerIconPainter: TickMarkerIconPainter(),
                          activeMarker: chartConfigModel.activeMarker,
                        ),
                        dataFitEnabled: true,
                        hideCrosshair: true,
                        //  isLive: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ));
}
