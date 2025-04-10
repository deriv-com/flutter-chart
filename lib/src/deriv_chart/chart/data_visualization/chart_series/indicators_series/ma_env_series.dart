import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/channel_fill_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
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
import '../../chart_data.dart';
import '../data_series.dart';
import '../series.dart';
import '../series_painter.dart';
import 'ma_series.dart';
import 'models/ma_env_options.dart';
import 'single_indicator_series.dart';

/// A series which shows Moving Average Envelope data calculated from 'entries'.
class MAEnvSeries extends Series {
  /// Initializes a series which shows shows moving Average data calculated
  /// from `entries`.
  ///
  /// [maEnvOptions] Moving Average Envelope indicator options.
  MAEnvSeries(
    IndicatorInput indicatorInput, {
    String? id,
    MAEnvOptions? maEnvOptions,
  }) : this.fromIndicator(
          CloseValueIndicator<Tick>(indicatorInput),
          id: id,
          maEnvOptions: maEnvOptions,
        );

  /// Initializes
  MAEnvSeries.fromIndicator(
    Indicator<Tick> indicator, {
    String? id,
    this.maEnvOptions,
  })  : _fieldIndicator = indicator,
        super(id ?? 'MAEnv$maEnvOptions');

  final Indicator<Tick> _fieldIndicator;

  /// Moving Average Envelope options
  MAEnvOptions? maEnvOptions;

  /// Lower series
  late SingleIndicatorSeries lowerSeries;

  /// Middle series
  late SingleIndicatorSeries middleSeries;

  /// Upper series
  late SingleIndicatorSeries upperSeries;

  /// Inner Series
  final List<Series> innerSeries = <Series>[];

  @override
  SeriesPainter<Series>? createPainter() {
    final CachedIndicator<Tick> smaIndicator =
        MASeries.getMAIndicator(_fieldIndicator, maEnvOptions!);

    lowerSeries = SingleIndicatorSeries(
      painterCreator: (
        Series series,
      ) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => MAEnvLowerIndicator<Tick>(
        smaIndicator,
        maEnvOptions!.shiftType,
        maEnvOptions!.shift,
      ),
      inputIndicator: _fieldIndicator,
      options: maEnvOptions,
      style: maEnvOptions!.lowerLineStyle,
      lastTickIndicatorStyle: getLastIndicatorStyle(
        maEnvOptions!.lowerLineStyle.color,
        showLastIndicator: maEnvOptions!.showLastIndicator,
      ),
    );

    middleSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => smaIndicator,
      inputIndicator: _fieldIndicator,
      options: maEnvOptions,
      style: maEnvOptions!.middleLineStyle,
      lastTickIndicatorStyle: getLastIndicatorStyle(
        maEnvOptions!.middleLineStyle.color,
        showLastIndicator: maEnvOptions!.showLastIndicator,
      ),
    );

    upperSeries = SingleIndicatorSeries(
      painterCreator: (Series series) =>
          LinePainter(series as DataSeries<Tick>),
      indicatorCreator: () => MAEnvUpperIndicator<Tick>(
        smaIndicator,
        maEnvOptions!.shiftType,
        maEnvOptions!.shift,
      ),
      inputIndicator: _fieldIndicator,
      options: maEnvOptions,
      style: maEnvOptions!.upperLineStyle,
      lastTickIndicatorStyle: getLastIndicatorStyle(
        maEnvOptions!.upperLineStyle.color,
        showLastIndicator: maEnvOptions!.showLastIndicator,
      ),
    );

    innerSeries
      ..add(lowerSeries)
      ..add(middleSeries)
      ..add(upperSeries);

    return ChannelFillPainter(
      upperSeries,
      lowerSeries,
      firstUpperChannelFillColor:
          maEnvOptions?.fillColor.withValues(alpha: 0.2),
      secondUpperChannelFillColor:
          maEnvOptions?.fillColor.withValues(alpha: 0.2),
    );
  }

  @override
  bool didUpdate(ChartData? oldData) {
    final MAEnvSeries? series = oldData as MAEnvSeries?;

    final bool _lowerUpdated = lowerSeries.didUpdate(series?.lowerSeries);
    final bool _middleUpdated = middleSeries.didUpdate(series?.middleSeries);
    final bool _upperUpdated = upperSeries.didUpdate(series?.upperSeries);

    return _lowerUpdated || _middleUpdated || _upperUpdated;
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
      // TODO(Ramin): Maybe later we can have these code and getMin/MaxEpochs in a parent class for Indicators like MAEnv, Ichimoku, Bollinger, etc
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

    return maEnvOptions != (previous as MAEnvSeries).maEnvOptions;
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

    if (maEnvOptions != null &&
        maEnvOptions!.showChannelFill &&
        upperSeries.visibleEntries.isNotEmpty &&
        lowerSeries.visibleEntries.isNotEmpty) {
      super.paint(canvas, size, epochToX, quoteToY, animationInfo, chartConfig,
          theme, chartScaleModel);
    }
  }

  @override
  int? getMaxEpoch() => innerSeries.getMaxEpoch();

  @override
  int? getMinEpoch() => innerSeries.getMinEpoch();
}
