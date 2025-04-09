import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/indicator.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import '../data_series.dart';
import '../series.dart';
import '../series_painter.dart';
import 'fractals_series/arrow_painter.dart';
import 'fractals_series/custom_bearish_indicator.dart';
import 'fractals_series/custom_bullish_indicator.dart';
import 'models/alligator_options.dart';
import 'single_indicator_series.dart';

/// A series which shows Alligator Series data calculated from 'entries'.
class AlligatorSeries extends Series {
  /// Initializes a series which shows shows Alligator data calculated from
  /// [indicatorInput].
  ///
  /// [alligatorOptions] Alligator indicator options.
  AlligatorSeries(
    IndicatorInput indicatorInput, {
    required this.alligatorOptions,
    String? id,
  })  : _fieldIndicator = HL2Indicator<Tick>(indicatorInput),
        _indicatorInput = indicatorInput,
        super(id ?? 'Alligator$alligatorOptions');

  final Indicator<Tick> _fieldIndicator;
  final IndicatorInput _indicatorInput;

  /// Alligator options
  AlligatorOptions alligatorOptions;

  /// Jaw series
  SingleIndicatorSeries? jawSeries;

  /// Teeth series
  SingleIndicatorSeries? teethSeries;

  /// Lips series
  SingleIndicatorSeries? lipsSeries;

  /// Bullish Series
  SingleIndicatorSeries? bullishSeries;

  /// Bearish Series
  SingleIndicatorSeries? bearishSeries;

  @override
  SeriesPainter<Series>? createPainter() {
    if (alligatorOptions.showLines) {
      jawSeries = SingleIndicatorSeries(
        painterCreator: (Series series) =>
            LinePainter(series as DataSeries<Tick>),
        indicatorCreator: () =>
            MMAIndicator<Tick>(_fieldIndicator, alligatorOptions.jawPeriod),
        inputIndicator: _fieldIndicator,
        options: alligatorOptions,
        style: alligatorOptions.jawLineStyle,
        offset: alligatorOptions.jawOffset,
        lastTickIndicatorStyle: getLastIndicatorStyle(
          alligatorOptions.jawLineStyle.color,
          showLastIndicator: alligatorOptions.showLastIndicator,
        ),
      );

      teethSeries = SingleIndicatorSeries(
        painterCreator: (
          Series series,
        ) =>
            LinePainter(series as DataSeries<Tick>),
        indicatorCreator: () => MMAIndicator<Tick>(
          _fieldIndicator,
          alligatorOptions.teethPeriod,
        ),
        inputIndicator: _fieldIndicator,
        options: alligatorOptions,
        style: alligatorOptions.teethLineStyle,
        offset: alligatorOptions.teethOffset,
        lastTickIndicatorStyle: getLastIndicatorStyle(
          alligatorOptions.teethLineStyle.color,
          showLastIndicator: alligatorOptions.showLastIndicator,
        ),
      );

      lipsSeries = SingleIndicatorSeries(
        painterCreator: (
          Series series,
        ) =>
            LinePainter(series as DataSeries<Tick>),
        indicatorCreator: () =>
            MMAIndicator<Tick>(_fieldIndicator, alligatorOptions.lipsPeriod),
        inputIndicator: _fieldIndicator,
        options: alligatorOptions,
        style: alligatorOptions.lipsLineStyle,
        offset: alligatorOptions.lipsOffset,
        lastTickIndicatorStyle: getLastIndicatorStyle(
          alligatorOptions.lipsLineStyle.color,
          showLastIndicator: alligatorOptions.showLastIndicator,
        ),
      );
    }

    if (alligatorOptions.showFractal) {
      bearishSeries = SingleIndicatorSeries(
        painterCreator: (
          Series series,
        ) =>
            ArrowPainter(series as DataSeries<Tick>, isUpward: true),
        indicatorCreator: () => CustomBearishIndicator(_indicatorInput),
        inputIndicator: _fieldIndicator,
        options: alligatorOptions,
        style: const LineStyle(color: Colors.redAccent),
      );
      bullishSeries = SingleIndicatorSeries(
        painterCreator: (
          Series series,
        ) =>
            ArrowPainter(series as DataSeries<Tick>),
        indicatorCreator: () => CustomBullishIndicator(_indicatorInput),
        inputIndicator: _fieldIndicator,
        options: alligatorOptions,
        style: const LineStyle(color: Colors.redAccent),
      );
    }

    return null;
  }

  @override
  bool didUpdate(ChartData? oldData) {
    final AlligatorSeries? series = oldData as AlligatorSeries?;

    final bool _jawUpdated = jawSeries?.didUpdate(series?.jawSeries) ?? false;
    final bool _teethUpdated =
        teethSeries?.didUpdate(series?.teethSeries) ?? false;
    final bool _lipsUpdated =
        lipsSeries?.didUpdate(series?.lipsSeries) ?? false;

    final bool _bearishUpdated =
        bearishSeries?.didUpdate(series?.bearishSeries) ?? false;
    final bool _bullishUpdated =
        bullishSeries?.didUpdate(series?.bullishSeries) ?? false;

    return _jawUpdated ||
        _teethUpdated ||
        _lipsUpdated ||
        _bullishUpdated ||
        _bearishUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    jawSeries?.update(leftEpoch, rightEpoch);
    teethSeries?.update(leftEpoch, rightEpoch);
    lipsSeries?.update(leftEpoch, rightEpoch);
    bullishSeries?.update(leftEpoch, rightEpoch);
    bearishSeries?.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() => <double>[
        <ChartData?>[
          jawSeries,
          teethSeries,
          lipsSeries,
        ].getMinValue(),
        <ChartData?>[
          jawSeries,
          teethSeries,
          lipsSeries,
        ].getMaxValue()
      ];

  @override
  bool shouldRepaint(ChartData? previous) {
    if (previous == null) {
      return true;
    }

    return alligatorOptions != (previous as AlligatorSeries).alligatorOptions;
  }

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
    jawSeries?.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);
    teethSeries?.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);
    lipsSeries?.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);
    bearishSeries?.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);
    bullishSeries?.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);
  }

  @override
  int? getMaxEpoch() =>
      <ChartData?>[jawSeries, teethSeries, lipsSeries].getMaxEpoch();

  @override
  int? getMinEpoch() =>
      <ChartData?>[jawSeries, teethSeries, lipsSeries].getMinEpoch();
}
