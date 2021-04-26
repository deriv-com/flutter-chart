// @dart=2.9

import 'dart:math';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/ichimoku_clouds/ichimoku_cloud_indicator_config.dart';
import 'package:deriv_chart/src/helpers/helper_functions.dart';
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
  }) : super(id ?? 'Ichimoku$ichimokuCloudOptions');

  /*late*/SingleIndicatorSeries _conversionLineSeries;
  /*late*/SingleIndicatorSeries _baseLineSeries;
  /*late*/SingleIndicatorSeries _laggingSpanSeries;
  /*late*/SingleIndicatorSeries _spanASeries;
  /*late*/SingleIndicatorSeries _spanBSeries;
  final List<SingleIndicatorSeries> _ichimokuSeries = <SingleIndicatorSeries>[];

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

    _ichimokuSeries
      ..add(_conversionLineSeries)
      ..add(_baseLineSeries)
      ..add(_laggingSpanSeries)
      ..add(_spanASeries)
      ..add(_spanBSeries);

    return null;
  }

  @override
  bool didUpdate(ChartData oldData) {
    final IchimokuCloudSeries series = oldData;

    final bool conversionLineUpdated =
        _conversionLineSeries?.didUpdate(series?._conversionLineSeries) ??
            false;
    final bool baseLineUpdated =
        _baseLineSeries?.didUpdate(series?._baseLineSeries) ?? false;
    final bool laggingSpanUpdated =
        _laggingSpanSeries?.didUpdate(series?._laggingSpanSeries) ?? false;
    final bool spanAUpdated =
        _spanASeries?.didUpdate(series?._spanASeries) ?? false;
    final bool spanBUpdated =
        _spanBSeries?.didUpdate(series?._spanBSeries) ?? false;

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
    _spanASeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);
    _spanBSeries.paint(
        canvas, size, epochToX, quoteToY, animationInfo, chartConfig, theme);

    // TODO(ramin): call super.paint to paint the Channels fill.
  }

  @override
  int getMaxEpoch() => _ichimokuSeries.getMaxEpoch();

  @override
  int getMinEpoch() => _ichimokuSeries.getMinEpoch();
}
