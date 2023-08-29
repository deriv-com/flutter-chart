import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/ichimoku_clouds/ichimoku_cloud_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/channel_fill_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/helper_functions.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import 'models/ichimoku_clouds_options.dart';
import 'single_indicator_series.dart';

/// Ichimoku Cloud series
class IchimokuCloudSeries extends Series {
  /// Initializes
  IchimokuCloudSeries(
    this.ticks, {
    required this.ichimokuCloudOptions,
    required this.config,
    String? id,
  }) : super(id ?? 'Ichimoku$ichimokuCloudOptions');

  late SingleIndicatorSeries conversionLineSeries;
  late SingleIndicatorSeries baseLineSeries;
  late SingleIndicatorSeries laggingSpanSeries;
  late SingleIndicatorSeries spanASeries;
  late SingleIndicatorSeries spanBSeries;
  final List<SingleIndicatorSeries> ichimokuSeries = <SingleIndicatorSeries>[];

  /// List of [Tick]s to calculate IchimokuCloud on.
  final IndicatorDataInput ticks;

  /// Ichimoku Clouds Configuration.
  IchimokuCloudIndicatorConfig config;

  /// Ichimoku Clouds Options.
  IchimokuCloudOptions ichimokuCloudOptions;

  @override
  SeriesPainter<Series>? createPainter() {
    final CloseValueIndicator<Tick> closeValueIndicator =
        CloseValueIndicator<Tick>(ticks);

    final IchimokuBaseLineIndicator<Tick> baseLineIndicator =
        IchimokuBaseLineIndicator<Tick>(
      ticks,
      period: ichimokuCloudOptions.baseLinePeriod,
    );

    final IchimokuConversionLineIndicator<Tick> conversionLineIndicator =
        IchimokuConversionLineIndicator<Tick>(
      ticks,
      period: ichimokuCloudOptions.conversionLinePeriod,
    );

    final IchimokuLaggingSpanIndicator<Tick> laggingSpanIndicator =
        IchimokuLaggingSpanIndicator<Tick>(ticks);

    final IchimokuSpanAIndicator<Tick> spanAIndicator =
        IchimokuSpanAIndicator<Tick>(
      ticks,
      conversionLineIndicator: conversionLineIndicator,
      baseLineIndicator: baseLineIndicator,
    );

    final IchimokuSpanBIndicator<Tick> spanBIndicator =
        IchimokuSpanBIndicator<Tick>(
      ticks,
      period: ichimokuCloudOptions.leadingSpanBPeriod,
    );

    conversionLineSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => conversionLineIndicator,
      inputIndicator: closeValueIndicator,
      options: ichimokuCloudOptions,
      style: config.conversionLineStyle,
    );

    baseLineSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => baseLineIndicator,
      inputIndicator: closeValueIndicator,
      options: ichimokuCloudOptions,
      style: config.baseLineStyle,
    );

    laggingSpanSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => laggingSpanIndicator,
      inputIndicator: closeValueIndicator,
      options: ichimokuCloudOptions,
      offset: config.laggingSpanOffset,
      style: config.laggingLineStyle,
    );

    spanASeries = SingleIndicatorSeries(
      painterCreator: (Series series) => null,
      indicatorCreator: () => spanAIndicator,
      inputIndicator: closeValueIndicator,
      options: ichimokuCloudOptions,
      offset: ichimokuCloudOptions.baseLinePeriod,
      style: config.spanALineStyle,
    );

    spanBSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => null,
      indicatorCreator: () => spanBIndicator,
      inputIndicator: closeValueIndicator,
      options: ichimokuCloudOptions,
      offset: ichimokuCloudOptions.baseLinePeriod,
      style: config.spanBLineStyle,
    );

    ichimokuSeries
      ..add(conversionLineSeries)
      ..add(baseLineSeries)
      ..add(laggingSpanSeries)
      ..add(spanASeries)
      ..add(spanBSeries);

    return ChannelFillPainter(
      spanASeries,
      spanBSeries,
      firstUpperChannelFillColor: config.spanALineStyle.color.withOpacity(0.2),
      secondUpperChannelFillColor: config.spanBLineStyle.color.withOpacity(0.2),
    );
  }

  @override
  bool didUpdate(ChartData? oldData) {
    final IchimokuCloudSeries? series = oldData as IchimokuCloudSeries?;

    final bool conversionLineUpdated =
        conversionLineSeries.didUpdate(series?.conversionLineSeries);
    final bool baseLineUpdated =
        baseLineSeries.didUpdate(series?.baseLineSeries);
    final bool laggingSpanUpdated =
        laggingSpanSeries.didUpdate(series?.laggingSpanSeries);
    final bool spanAUpdated = spanASeries.didUpdate(series?.spanASeries);
    final bool spanBUpdated = spanBSeries.didUpdate(series?.spanBSeries);

    return conversionLineUpdated ||
        baseLineUpdated ||
        laggingSpanUpdated ||
        spanAUpdated ||
        spanBUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    conversionLineSeries.update(leftEpoch, rightEpoch);
    baseLineSeries.update(leftEpoch, rightEpoch);
    laggingSpanSeries.update(leftEpoch, rightEpoch);
    spanASeries.update(leftEpoch, rightEpoch);
    spanBSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() {
    final double minValue = ichimokuSeries
        .map((SingleIndicatorSeries series) => series.minValue)
        .reduce(safeMin);

    final double maxValue = ichimokuSeries
        .map((SingleIndicatorSeries series) => series.maxValue)
        .reduce(safeMax);

    return <double>[minValue, maxValue];
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
  ) {
    conversionLineSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    baseLineSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    laggingSpanSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    super.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);

    if (animationInfo.currentTickPercent == 1) {
      spanASeries.resetLastEntryAnimation();
      spanBSeries.resetLastEntryAnimation();
    }
  }

  @override
  int? getMaxEpoch() => ichimokuSeries.getMaxEpoch();

  @override
  int? getMinEpoch() => ichimokuSeries.getMinEpoch();
}
