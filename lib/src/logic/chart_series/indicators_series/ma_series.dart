import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:flutter/material.dart';

import '../series.dart';
import '../series_painter.dart';
import 'abstract_single_indicator_series.dart';
import 'models/indicator_options.dart';

/// A series which shows Moving Average data calculated from [entries].
class MASeries extends AbstractSingleIndicatorSeries {
  /// Initializes a series which shows shows moving Average data calculated from [entries].
  ///
  /// [period] is the average of this number of past data which will be calculated as MA value
  /// [type] The type of moving average.
  MASeries(
    IndicatorInput indicatorInput,
    MAOptions options, {
    String id,
    LineStyle style,
  }) : this.fromIndicator(
          CloseValueIndicator<Tick>(indicatorInput),
          id: id,
          options: options,
          style: style,
        );

  /// Initializes
  MASeries.fromIndicator(
    Indicator<Tick> indicator, {
    String id,
    LineStyle style,
    MAOptions options,
  }) : super(
          indicator,
          id ?? 'SMASeries-period${options.period}-type${options.type}',
          options,
          style: style ??
              const LineStyle(
                  thickness: 0.5, lastTickStyle: HorizontalBarrierStyle(color: Colors.pink,hasLine: false)),
        );

  @override
  SeriesPainter<Series> createPainter() => LinePainter(this);

  @override
  CachedIndicator<Tick> initializeIndicator() =>
      MASeries.getMAIndicator(inputIndicator, options);

  /// Returns a moving average indicator based on [period] and its [type].
  static CachedIndicator<Tick> getMAIndicator(
    Indicator<Tick> indicator,
    MAOptions maOptions,
  ) {
    switch (maOptions.type) {
      case MovingAverageType.exponential:
        return EMAIndicator<Tick>(indicator, maOptions.period);
      case MovingAverageType.weighted:
        return WMAIndicator<Tick>(indicator, maOptions.period);
      case MovingAverageType.hull:
        return HMAIndicator<Tick>(indicator, maOptions.period);
      case MovingAverageType.zeroLag:
        return ZLEMAIndicator<Tick>(indicator, maOptions.period);
      default:
        return SMAIndicator<Tick>(indicator, maOptions.period);
    }
  }
}

/// Supported types of moving average.
enum MovingAverageType {
  /// Simple
  simple,

  /// Exponential
  exponential,

  /// Weighted
  weighted,

  /// Hull
  hull,

  /// Zero-lag exponential
  zeroLag,
}
