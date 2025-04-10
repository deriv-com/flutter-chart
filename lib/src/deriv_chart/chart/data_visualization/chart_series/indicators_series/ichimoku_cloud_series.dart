import 'package:deriv_chart/src/add_ons/indicators_ui/ichimoku_clouds/ichimoku_cloud_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/channel_fill_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/helper_functions.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/indicator.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import '../data_series.dart';
import '../series.dart';
import '../series_painter.dart';
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

  /// Conversion line series.
  late SingleIndicatorSeries conversionLineSeries;

  /// Base line series.
  late SingleIndicatorSeries baseLineSeries;

  /// Lagging line series.
  late SingleIndicatorSeries laggingSpanSeries;

  /// SpanA line series.
  late SingleIndicatorSeries spanASeries;

  /// SpanB line series.
  late SingleIndicatorSeries spanBSeries;

  /// Ichimoku series.
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
      lastTickIndicatorStyle: getLastIndicatorStyle(
        config.conversionLineStyle.color,
        showLastIndicator: config.showLastIndicator,
      ),
    );

    baseLineSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => baseLineIndicator,
      inputIndicator: closeValueIndicator,
      options: ichimokuCloudOptions,
      style: config.baseLineStyle,
      lastTickIndicatorStyle: getLastIndicatorStyle(
        config.baseLineStyle.color,
        showLastIndicator: config.showLastIndicator,
      ),
    );

    laggingSpanSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => laggingSpanIndicator,
      inputIndicator: closeValueIndicator,
      options: ichimokuCloudOptions,
      offset: config.laggingSpanOffset,
      style: config.laggingLineStyle,
      lastTickIndicatorStyle: getLastIndicatorStyle(
        config.laggingLineStyle.color,
        showLastIndicator: config.showLastIndicator,
      ),
    );

    spanASeries = SingleIndicatorSeries(
      painterCreator: (Series series) => null,
      indicatorCreator: () => spanAIndicator,
      inputIndicator: closeValueIndicator,
      options: ichimokuCloudOptions,
      offset: ichimokuCloudOptions.baseLinePeriod,
      style: config.spanALineStyle,
      lastTickIndicatorStyle: getLastIndicatorStyle(
        config.spanALineStyle.color,
        showLastIndicator: config.showLastIndicator,
      ),
    );

    spanBSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => null,
      indicatorCreator: () => spanBIndicator,
      inputIndicator: closeValueIndicator,
      options: ichimokuCloudOptions,
      offset: ichimokuCloudOptions.baseLinePeriod,
      style: config.spanBLineStyle,
      lastTickIndicatorStyle: getLastIndicatorStyle(
        config.spanBLineStyle.color,
        showLastIndicator: config.showLastIndicator,
      ),
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
      firstUpperChannelFillColor:
          config.spanALineStyle.color.withValues(alpha: 0.2),
      secondUpperChannelFillColor:
          config.spanBLineStyle.color.withValues(alpha: 0.2),
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
  bool shouldRepaint(ChartData? previous) {
    if (previous == null) {
      return true;
    }

    final IchimokuCloudSeries oldSeries = previous as IchimokuCloudSeries;
    return config.toJson().toString() != oldSeries.config.toJson().toString();
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
    conversionLineSeries.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);
    baseLineSeries.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);
    laggingSpanSeries.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);
    spanASeries.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);
    spanBSeries.paint(canvas, size, epochToX, quoteToY, animationInfo,
        chartConfig, theme, chartScaleModel);
    super.paint(canvas, size, epochToX, quoteToY, animationInfo, chartConfig,
        theme, chartScaleModel);

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
