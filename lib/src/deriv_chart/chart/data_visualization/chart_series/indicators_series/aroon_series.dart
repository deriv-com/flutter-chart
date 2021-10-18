import 'package:deriv_chart/src/add_ons/indicators_ui/aroon/aroon_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/aroon_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/single_indicator_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
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

  late SingleIndicatorSeries _aroonUpSeries;
  late SingleIndicatorSeries _aroonDownSeries;

  /// options
  AroonOptions aroonOption;

  @override
  SeriesPainter<Series>? createPainter() {
    _aroonUpSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => AroonUpIndicator<Tick>.fromIndicator(
          HighValueIndicator<Tick>(indicatorInput),
          period: indicatorConfig.period),
      inputIndicator: CloseValueIndicator<Tick>(indicatorInput),
      style: const LineStyle(color: Colors.green),
      options: aroonOption,
    );
    _aroonDownSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => AroonDownIndicator<Tick>.fromIndicator(
          LowValueIndicator<Tick>(indicatorInput),
          period: indicatorConfig.period),
      inputIndicator: CloseValueIndicator<Tick>(indicatorInput),
      options: aroonOption,
      style: const LineStyle(color: Colors.red),
    );

    return null;
  }

  @override
  bool didUpdate(ChartData? oldData) {
    final AroonSeries? series = oldData as AroonSeries?;
    final bool _aroonUpUpdated =
        _aroonUpSeries.didUpdate(series?._aroonUpSeries);
    final bool _aroonDownUpdated =
        _aroonDownSeries.didUpdate(series?._aroonDownSeries);
    return _aroonUpUpdated || _aroonDownUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _aroonUpSeries.update(leftEpoch, rightEpoch);
    _aroonDownSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() => <double>[
        <ChartData>[
          _aroonUpSeries,
          _aroonDownSeries,
        ].getMinValue(),
        <ChartData>[
          _aroonUpSeries,
          _aroonDownSeries,
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
  ) {
    _aroonDownSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _aroonUpSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
  }

  @override
  int? getMaxEpoch() => <ChartData>[
        _aroonDownSeries,
        _aroonUpSeries,
      ].getMaxEpoch();

  @override
  int? getMinEpoch() => <ChartData>[
        _aroonDownSeries,
        _aroonUpSeries,
      ].getMinEpoch();
}
