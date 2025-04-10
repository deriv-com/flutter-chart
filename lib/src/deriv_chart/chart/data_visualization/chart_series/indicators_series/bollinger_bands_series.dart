import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/channel_fill_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/helper_functions.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/indicator.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import 'models/bollinger_bands_options.dart';
import 'single_indicator_series.dart';

/// Bollinger bands series
class BollingerBandSeries extends Series {
  /// Initializes
  ///
  /// Close values will be chosen by default.
  BollingerBandSeries(
    IndicatorInput indicatorInput, {
    required BollingerBandsOptions bbOptions,
    String? id,
  }) : this.fromIndicator(
          CloseValueIndicator<Tick>(indicatorInput),
          bbOptions: bbOptions,
          id: id,
        );

  /// Initializes
  BollingerBandSeries.fromIndicator(
    Indicator<Tick> indicator, {
    required this.bbOptions,
    String? id,
  })  : _fieldIndicator = indicator,
        super(id ?? 'Bollinger$bbOptions');

  /// Lower series
  late SingleIndicatorSeries lowerSeries;

  /// Middle series
  late SingleIndicatorSeries middleSeries;

  /// Upper series
  late SingleIndicatorSeries upperSeries;

  /// Inner Series
  final List<Series> innerSeries = <Series>[];

  /// Bollinger bands options
  final BollingerBandsOptions bbOptions;

  /// Field Indicator
  final Indicator<Tick> _fieldIndicator;

  @override
  SeriesPainter<Series>? createPainter() {
    final StandardDeviationIndicator<Tick> standardDeviation =
        StandardDeviationIndicator<Tick>(_fieldIndicator, bbOptions.period);

    final CachedIndicator<Tick> bbmSMA =
        MASeries.getMAIndicator(_fieldIndicator, bbOptions);

    middleSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => bbmSMA,
      inputIndicator: _fieldIndicator,
      options: bbOptions,
      style: bbOptions.middleLineStyle,
      lastTickIndicatorStyle: getLastIndicatorStyle(
        bbOptions.middleLineStyle.color,
        showLastIndicator: bbOptions.showLastIndicator,
      ),
    );

    lowerSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => BollingerBandsLowerIndicator<Tick>(
        bbmSMA,
        standardDeviation,
        k: bbOptions.standardDeviationFactor,
      ),
      inputIndicator: _fieldIndicator,
      options: bbOptions,
      style: bbOptions.lowerLineStyle,
      lastTickIndicatorStyle: getLastIndicatorStyle(
        bbOptions.lowerLineStyle.color,
        showLastIndicator: bbOptions.showLastIndicator,
      ),
    );

    upperSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => BollingerBandsUpperIndicator<Tick>(
        bbmSMA,
        standardDeviation,
        k: bbOptions.standardDeviationFactor,
      ),
      inputIndicator: _fieldIndicator,
      options: bbOptions,
      style: bbOptions.upperLineStyle,
      lastTickIndicatorStyle: getLastIndicatorStyle(
        bbOptions.upperLineStyle.color,
        showLastIndicator: bbOptions.showLastIndicator,
      ),
    );

    innerSeries
      ..add(lowerSeries)
      ..add(middleSeries)
      ..add(upperSeries);

    return ChannelFillPainter(
      upperSeries,
      lowerSeries,
      firstUpperChannelFillColor: bbOptions.fillColor.withValues(alpha: 0.2),
      secondUpperChannelFillColor: bbOptions.fillColor.withValues(alpha: 0.2),
    );
  }

  @override
  bool didUpdate(ChartData? oldData) {
    final BollingerBandSeries? series = oldData as BollingerBandSeries?;

    final bool lowerUpdated = lowerSeries.didUpdate(series?.lowerSeries);
    final bool middleUpdated = middleSeries.didUpdate(series?.middleSeries);
    final bool upperUpdated = upperSeries.didUpdate(series?.upperSeries);

    return lowerUpdated || middleUpdated || upperUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    lowerSeries.update(leftEpoch, rightEpoch);
    middleSeries.update(leftEpoch, rightEpoch);
    upperSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() =>
      // Can just use lowerSeries minValue for min and upperSeries maxValue
      // for max. But to be safe we calculate min and max. from all three series
      <double>[
        innerSeries
            .map((Series series) => series.minValue)
            .reduce((double a, double b) => safeMin(a, b)),
        innerSeries
            .map((Series series) => series.maxValue)
            .reduce((double a, double b) => safeMax(a, b)),
      ];

  @override
  bool shouldRepaint(ChartData? previous) {
    if (previous == null) {
      return true;
    }

    return bbOptions != (previous as BollingerBandSeries).bbOptions;
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
    lowerSeries.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);
    middleSeries.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);
    upperSeries.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);

    if (bbOptions.showChannelFill &&
        upperSeries.visibleEntries.isNotEmpty &&
        lowerSeries.visibleEntries.isNotEmpty) {
      super.paint(canvas, size, epochToX, quoteToY, animationInfo, chartConfig,
          theme, chartScaleModel);
    }
  }

  @override
  int? getMinEpoch() => innerSeries.getMinEpoch();

  @override
  int? getMaxEpoch() => innerSeries.getMaxEpoch();
}
