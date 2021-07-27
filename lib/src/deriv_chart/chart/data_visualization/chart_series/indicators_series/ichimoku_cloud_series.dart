import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/ichimoku_clouds/ichimoku_cloud_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/channel_fill_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/helper_functions.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
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

  late SingleIndicatorSeries _conversionLineSeries;
  late SingleIndicatorSeries _baseLineSeries;
  late SingleIndicatorSeries _laggingSpanSeries;
  late SingleIndicatorSeries _spanASeries;
  late SingleIndicatorSeries _spanBSeries;
  final List<SingleIndicatorSeries> _ichimokuSeries = <SingleIndicatorSeries>[];

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

    _conversionLineSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => conversionLineIndicator,
      inputIndicator: closeValueIndicator,
      options: ichimokuCloudOptions,
      style: const LineStyle(
        color: Colors.indigo,
      ),
    );

    _baseLineSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => baseLineIndicator,
      inputIndicator: closeValueIndicator,
      options: ichimokuCloudOptions,
      style: const LineStyle(
        color: Colors.redAccent,
      ),
    );

    _laggingSpanSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => laggingSpanIndicator,
      inputIndicator: closeValueIndicator,
      options: ichimokuCloudOptions,
      offset: config.laggingSpanOffset,
      style: const LineStyle(
        color: Colors.lime,
      ),
    );

    _spanASeries = SingleIndicatorSeries(
      painterCreator: (Series series) => null,
      indicatorCreator: () => spanAIndicator,
      inputIndicator: closeValueIndicator,
      options: ichimokuCloudOptions,
      offset: ichimokuCloudOptions.baseLinePeriod,
      style: const LineStyle(
        color: Colors.green,
      ),
    );

    _spanBSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => null,
      indicatorCreator: () => spanBIndicator,
      inputIndicator: closeValueIndicator,
      options: ichimokuCloudOptions,
      offset: ichimokuCloudOptions.baseLinePeriod,
      style: const LineStyle(
        color: Colors.red,
      ),
    );

    _ichimokuSeries
      ..add(_conversionLineSeries)
      ..add(_baseLineSeries)
      ..add(_laggingSpanSeries)
      ..add(_spanASeries)
      ..add(_spanBSeries);

    return ChannelFillPainter(
      _spanASeries,
      _spanBSeries,
      firstUpperChannelFillColor: Colors.green.withOpacity(0.2),
      secondUpperChannelFillColor: Colors.red.withOpacity(0.2),
    );
  }

  @override
  bool didUpdate(ChartData? oldData) {
    final IchimokuCloudSeries? series = oldData as IchimokuCloudSeries?;

    final bool conversionLineUpdated =
        _conversionLineSeries.didUpdate(series?._conversionLineSeries);
    final bool baseLineUpdated =
        _baseLineSeries.didUpdate(series?._baseLineSeries);
    final bool laggingSpanUpdated =
        _laggingSpanSeries.didUpdate(series?._laggingSpanSeries);
    final bool spanAUpdated = _spanASeries.didUpdate(series?._spanASeries);
    final bool spanBUpdated = _spanBSeries.didUpdate(series?._spanBSeries);

    return conversionLineUpdated ||
        baseLineUpdated ||
        laggingSpanUpdated ||
        spanAUpdated ||
        spanBUpdated;
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    _conversionLineSeries.update(leftEpoch, rightEpoch);
    _baseLineSeries.update(leftEpoch, rightEpoch);
    _laggingSpanSeries.update(leftEpoch, rightEpoch);
    _spanASeries.update(leftEpoch, rightEpoch);
    _spanBSeries.update(leftEpoch, rightEpoch);
  }

  @override
  List<double> recalculateMinMax() {
    final double minValue = _ichimokuSeries
        .map((SingleIndicatorSeries series) => series.minValue)
        .reduce(safeMin);

    final double maxValue = _ichimokuSeries
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
    _conversionLineSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _baseLineSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _laggingSpanSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    super.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);

    if (animationInfo.currentTickPercent == 1) {
      _spanASeries.resetLastEntryAnimation();
      _spanBSeries.resetLastEntryAnimation();
    }
  }

  @override
  int? getMaxEpoch() => _ichimokuSeries.getMaxEpoch();

  @override
  int? getMinEpoch() => _ichimokuSeries.getMinEpoch();
}
