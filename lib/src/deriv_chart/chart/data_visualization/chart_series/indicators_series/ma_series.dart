import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import '../series.dart';
import '../series_painter.dart';
import 'abstract_single_indicator_series.dart';
import 'models/indicator_options.dart';

/// A series which shows Moving Average data calculated from [entries].
class MASeries extends AbstractSingleIndicatorSeries {
  /// Initializes a series which shows shows moving Average data calculated from [entries].
  ///
  /// [options]   Options of this [MASeries].
  MASeries(
    IndicatorInput indicatorInput,
    MAOptions options, {
    String? id,
    LineStyle? style,
    int offset = 0,
  }) : this.fromIndicator(
          CloseValueIndicator<Tick>(indicatorInput),
          options,
          id: id,
          style: style,
          offset: offset,
        );

  /// Initializes
  MASeries.fromIndicator(
    Indicator<Tick> indicator,
    MAOptions options, {
    String? id,
    LineStyle? style,
    int offset = 0,
  }) : super(
          indicator,
          id ?? 'SMASeries-period${options.period}-type${options.type}',
          options,
          style: style ?? const LineStyle(thickness: 0.5),
          offset: offset,
        );

  @override
  SeriesPainter<Series> createPainter() => LinePainter(this);

  @override
  CachedIndicator<Tick> initializeIndicator() =>
      MASeries.getMAIndicator(inputIndicator, options as MAOptions);

  /// Returns a moving average indicator based on [maOptions] values.
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
      case MovingAverageType.timeSeries:
        return LSMAIndicator<Tick>(indicator, maOptions.period);
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

  /// Time Series
  timeSeries,
}
