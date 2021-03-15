import 'dart:math';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/ichimoku_clouds/ichimoku_cloud_indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/ichimoku_clouds_options.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/single_indicator_series.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

/// Ichimoku Cloud series
class IchimokuCloudSeries extends Series {
  /// Initializes
  IchimokuCloudSeries(
    this.ticks, {
    @required this.ichimokuCloudOptions,
    @required this.config,
    String id,
  }) : super(id);

  SingleIndicatorSeries _conversionLineSeries;
  SingleIndicatorSeries _baseLineSeries;
  SingleIndicatorSeries _laggingSpanSeries;
  SingleIndicatorSeries _spanASeries;
  SingleIndicatorSeries _spanBSeries;

  /// List of [Tick]s to calculate IchimokuCloud on.
  final IndicatorDataInput ticks;

  /// Ichimoku Clouds Configuration.
  IchimokuCloudIndicatorConfig config;

  /// Ichimoku Clouds Options.
  IchimokuCloudOptions ichimokuCloudOptions;

  @override
  SeriesPainter<Series> createPainter() {
    final CloseValueIndicator<Tick> closeValueIndicator =
        CloseValueIndicator<Tick>(ticks);
    final IchimokuBaseLineIndicator<Tick> baseLineIndicator =
        IchimokuBaseLineIndicator<Tick>(ticks,
            period: ichimokuCloudOptions.baseLinePeriod);

    final IchimokuConversionLineIndicator<Tick> conversionLineIndicator =
        IchimokuConversionLineIndicator<Tick>(ticks,
            period: ichimokuCloudOptions.conversionLinePeriod);

    final IchimokuLaggingSpanIndicator<Tick> laggingSpanIndicator =
        IchimokuLaggingSpanIndicator<Tick>(ticks);

    final IchimokuSpanAIndicator<Tick> spanAIndicator =
        IchimokuSpanAIndicator<Tick>(ticks,
            conversionLineIndicator: conversionLineIndicator,
            baseLineIndicator: baseLineIndicator);

    final IchimokuSpanBIndicator<Tick> spanBIndicator =
        IchimokuSpanBIndicator<Tick>(ticks);

    _conversionLineSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => LinePainter(series),
      indicatorCreator: () => conversionLineIndicator,
      inputIndicator: closeValueIndicator,
      options: ichimokuCloudOptions,
      style: const LineStyle(
        color: Colors.indigo,
      ),
    );

    _baseLineSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => LinePainter(series),
      indicatorCreator: () => baseLineIndicator,
      inputIndicator: closeValueIndicator,
      options: ichimokuCloudOptions,
      style: const LineStyle(
        color: Colors.redAccent,
      ),
    );

    // TODO(mohammadamir-fs): add offset to line painter
    _laggingSpanSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => LinePainter(series),
      indicatorCreator: () => laggingSpanIndicator,
      inputIndicator: closeValueIndicator,
      options: ichimokuCloudOptions,
      offset: config.laggingSpanOffset,
      style: const LineStyle(
        color: Colors.lime,
      ),
    );

    _spanASeries = SingleIndicatorSeries(
      painterCreator: (Series series) => LinePainter(series),
      indicatorCreator: () => spanAIndicator,
      inputIndicator: closeValueIndicator,
      options: ichimokuCloudOptions,
      offset: ichimokuCloudOptions.baseLinePeriod,
      style: const LineStyle(
        color: Colors.green,
      ),
    );

    _spanBSeries = SingleIndicatorSeries(
      painterCreator: (Series series) => LinePainter(series),
      indicatorCreator: () => spanBIndicator,
      inputIndicator: closeValueIndicator,
      options: ichimokuCloudOptions,
      offset: ichimokuCloudOptions.baseLinePeriod,
      style: const LineStyle(
        color: Colors.red,
      ),
    );

    return null; // TODO(ramin): return the painter that paints Channel Fill between bands
  }

  @override
  bool didUpdate(ChartData oldData) {
    final IchimokuCloudSeries series = oldData;

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
    double conversionLineMin = _conversionLineSeries.minValue;
    double conversionLineMax = _conversionLineSeries.maxValue;

    double baseLineMin = _baseLineSeries.minValue;
    double baseLineMax = _baseLineSeries.maxValue;

    double spanAMin = _spanASeries.minValue;
    double spanAMax = _spanASeries.maxValue;

    double spanBMin = _spanBSeries.minValue;
    double spanBMax = _spanBSeries.maxValue;

    double laggingSpanMin = _laggingSpanSeries.minValue;
    double laggingSpanMax = _laggingSpanSeries.maxValue;

    if (laggingSpanMin.isNaN) {
      laggingSpanMin = double.infinity;
    }

    if (laggingSpanMax.isNaN) {
      laggingSpanMax = double.negativeInfinity;
    }

    if (conversionLineMax.isNaN) {
      conversionLineMax = double.negativeInfinity;
    }

    if (conversionLineMin.isNaN) {
      conversionLineMin = double.infinity;
    }

    if (baseLineMin.isNaN) {
      baseLineMin = double.infinity;
    }

    if (baseLineMax.isNaN) {
      baseLineMax = double.negativeInfinity;
    }

    final double minimum = min(
        min(min(min(conversionLineMin, baseLineMin), laggingSpanMin),
            _spanBSeries.minValue),
        _spanASeries.minValue);
    final double maximum = max(
        max(max(max(conversionLineMax, baseLineMax), laggingSpanMax),
            _spanBSeries.maxValue),
        _spanASeries.maxValue);
    print(minimum);
    return <double>[minimum, maximum];
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
    _spanASeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _spanBSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);

    // TODO(ramin): call super.paint to paint the Channels fill.
  }

  @override
  int getMaxEpoch() {
    final double maxConversionLine =
        _conversionLineSeries.getMaxEpoch()?.toDouble() ??
            double.negativeInfinity;
    final double maxBaseLine =
        _baseLineSeries.getMaxEpoch()?.toDouble() ?? double.negativeInfinity;
    final double maxLaggingSpan =
        _laggingSpanSeries.getMaxEpoch()?.toDouble() ?? double.negativeInfinity;
    final double maxSpanALine =
        _spanASeries.getMaxEpoch()?.toDouble() ?? double.negativeInfinity;
    final double maxSpanBLine =
        _spanBSeries.getMaxEpoch()?.toDouble() ?? double.negativeInfinity;
    final double maximum = max<double>(
      max<double>(
        max<double>(
          max<double>(
            maxConversionLine,
            maxBaseLine,
          ),
          maxLaggingSpan,
        ),
        maxSpanALine,
      ),
      maxSpanBLine,
    );
    if (maximum == double.negativeInfinity) {
      return null;
    }
    return maximum.toInt();
  }

  @override
  int getMinEpoch() {
    final double minConversionLine =
        _conversionLineSeries.getMinEpoch()?.toDouble() ?? double.infinity;
    final double minBaseLine =
        _baseLineSeries.getMinEpoch()?.toDouble() ?? double.infinity;
    final double minLaggingSpan =
        _laggingSpanSeries.getMinEpoch()?.toDouble() ?? double.infinity;
    final double minSpanALine =
        _spanASeries.getMinEpoch()?.toDouble() ?? double.infinity;
    final double minSpanBLine =
        _spanBSeries.getMinEpoch()?.toDouble() ?? double.infinity;
    final double minimum = min<double>(
      min<double>(
        min<double>(
          min<double>(
            minConversionLine,
            minBaseLine,
          ),
          minLaggingSpan,
        ),
        minSpanALine,
      ),
      minSpanBLine,
    );
    if (minimum == double.infinity) {
      return null;
    }
    return minimum.toInt();
  }
}
