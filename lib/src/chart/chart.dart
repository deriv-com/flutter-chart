import 'dart:ui';

import 'package:deriv_chart/src/logic/annotations/chart_annotation.dart';
import 'package:deriv_chart/src/chart_controller.dart';
import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/markers/marker_series.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/chart_object.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../callbacks.dart';
import '../gestures/gesture_manager.dart';
import '../models/tick.dart';
import '../theme/chart_default_dark_theme.dart';
import '../theme/chart_default_light_theme.dart';
import '../theme/chart_theme.dart';
import '../x_axis/x_axis.dart';
import 'bottom_chart.dart';
import 'main_chart.dart';

/// Interactive chart widget.
class Chart extends StatelessWidget {
  /// Creates chart that expands to available space.
  const Chart({
    @required this.mainSeries,
    @required this.pipSize,
    @required this.granularity,
    this.controller,
    this.overlaySeries,
    this.bottomSeries,
    this.markerSeries,
    this.theme,
    this.onCrosshairAppeared,
    this.onVisibleAreaChanged,
    this.isLive = false,
    this.dataFitEnabled = false,
    this.opacity = 1.0,
    this.annotations,
    Key key,
  }) : super(key: key);

  /// Chart's main data series.
  final DataSeries<Tick> mainSeries;

  /// List of overlay indicator series to add on chart beside the [mainSeries].
  final List<Series> overlaySeries;

  /// List of bottom indicator series to add on chart separate from the [mainSeries].
  final List<Series> bottomSeries;

  /// Open position marker series.
  final MarkerSeries markerSeries;

  /// Chart's controller
  final ChartController controller;

  /// Number of digits after decimal point in price.
  final int pipSize;

  /// For candles: Duration of one candle in ms.
  /// For ticks: Average ms difference between two consecutive ticks.
  final int granularity;

  /// Called when crosshair details appear after long press.
  final VoidCallback onCrosshairAppeared;

  /// Called when chart is scrolled or zoomed.
  final VisibleAreaChangedCallback onVisibleAreaChanged;

  /// Chart's theme.
  final ChartTheme theme;

  /// Chart's annotations
  final List<ChartAnnotation<ChartObject>> annotations;

  /// Whether the chart should be showing live data or not.
  ///
  /// In case of being true the chart will keep auto-scrolling when its visible area
  /// is on the newest ticks/candles.
  final bool isLive;

  /// Starts in data fit mode and adds a data-fit button.
  final bool dataFitEnabled;

  /// Chart's opacity, Will be applied on the [mainSeries].
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final ChartTheme chartTheme =
        theme ?? (Theme.of(context).brightness == Brightness.dark
            ? ChartDefaultDarkTheme()
            : ChartDefaultLightTheme());

    final ChartConfig chartConfig = ChartConfig(
      pipSize: pipSize,
      granularity: granularity,
    );

    final List<ChartData> chartDataList = <ChartData>[
      mainSeries,
      if (overlaySeries != null) ...overlaySeries,
      if (bottomSeries != null) ...bottomSeries,
      if (annotations != null) ...annotations,
    ];

    return MultiProvider(
      providers: <SingleChildWidget>[
        Provider<ChartTheme>.value(value: chartTheme),
        Provider<ChartConfig>.value(value: chartConfig),
      ],
      child: Ink(
        color: chartTheme.base08Color,
        child: GestureManager(
          child: XAxis(
            maxEpoch: chartDataList.getMaxEpoch(),
            minEpoch: chartDataList.getMinEpoch(),
            entries: mainSeries.input,
            onVisibleAreaChanged: onVisibleAreaChanged,
            isLive: isLive,
            startWithDataFitMode: dataFitEnabled,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: MainChart(
                    controller: controller,
                    mainSeries: mainSeries,
                    overlaySeries: overlaySeries,
                    annotations: annotations,
                    markerSeries: markerSeries,
                    pipSize: pipSize,
                    onCrosshairAppeared: onCrosshairAppeared,
                    isLive: isLive,
                    showLoadingAnimationForHistoricalData: !dataFitEnabled,
                    showDataFitButton: dataFitEnabled,
                    opacity: opacity,
                  ),
                ),
                if (bottomSeries?.isNotEmpty ?? false)
                  ...bottomSeries
                      .map((Series series) => Expanded(
                              child: BottomChart(
                            series: series,
                            pipSize: pipSize,
                          )))
                      .toList()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
