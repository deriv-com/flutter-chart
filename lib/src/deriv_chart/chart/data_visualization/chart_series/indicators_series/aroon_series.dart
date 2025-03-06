import 'package:deriv_chart/src/add_ons/indicators_ui/aroon/aroon_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/aroon_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/single_indicator_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/indicator.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import '../series.dart';
import '../series_painter.dart';

/// A series which shows Aroon Indicator Series data calculated from 'entries'.
class AroonSeries extends Series {
  /// Initializes
  AroonSeries(
    this.indicatorInput,
    this.indicatorConfig, {
    required this.aroonOption,
    String? id,
  }) : super(id ?? 'Aroon$aroonOption');

  ///input data
  final IndicatorInput indicatorInput;

  /// Configs for `ArronIndicator`
  final AroonIndicatorConfig indicatorConfig;

  /// Arron up series
  late SingleIndicatorSeries aroonUpSeries;

  /// Arron down series
  late SingleIndicatorSeries aroonDownSeries;

  /// options
  AroonOptions aroonOption;

  @override
  SeriesPainter<Series>? createPainter() {
    aroonUpSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => AroonUpIndicator<Tick>.fromIndicator(
          HighValueIndicator<Tick>(indicatorInput),
          period: indicatorConfig.period),
      inputIndicator: CloseValueIndicator<Tick>(indicatorInput),
      style: indicatorConfig.upLineStyle,
      options: aroonOption,
      lastTickIndicatorStyle: getLastIndicatorStyle(
        indicatorConfig.upLineStyle.color,
        showLastIndicator: indicatorConfig.showLastIndicator,
      ),
    );
    aroonDownSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => AroonDownIndicator<Tick>.fromIndicator(
          LowValueIndicator<Tick>(indicatorInput),
          period: indicatorConfig.period),
      inputIndicator: CloseValueIndicator<Tick>(indicatorInput),
      options: aroonOption,
      style: indicatorConfig.downLineStyle,
      lastTickIndicatorStyle: getLastIndicatorStyle(
        indicatorConfig.downLineStyle.color,
        showLastIndicator: indicatorConfig.showLastIndicator,
      ),
    );

    return null;
  }

  @override
  bool didUpdate(ChartData? oldData) {
    final AroonSeries? series = oldData as AroonSeries?;
    final bool _aroonUpUpdated = aroonUpSeries.didUpdate(series?.aroonUpSeries);
    final bool _aroonDownUpdated =
        aroonDownSeries.didUpdate(series?.aroonDownSeries);
    return _aroonUpUpdated || _aroonDownUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    aroonUpSeries.update(leftEpoch, rightEpoch);
    aroonDownSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() => <double>[
        <ChartData>[
          aroonUpSeries,
          aroonDownSeries,
        ].getMinValue(),
        <ChartData>[
          aroonUpSeries,
          aroonDownSeries,
        ].getMaxValue()
      ];

  @override
  void paint(
    Canvas canvas,
    Size size,
    double Function(int) epochToX,
    double Function(double) quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme theme,
    ChartScaleModel chartScaleModel,
  ) {
    aroonDownSeries.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);
    aroonUpSeries.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);
  }

  @override
  int? getMaxEpoch() => <ChartData>[
        aroonDownSeries,
        aroonUpSeries,
      ].getMaxEpoch();

  @override
  int? getMinEpoch() => <ChartData>[
        aroonDownSeries,
        aroonUpSeries,
      ].getMinEpoch();
}
