import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/logic/indicators/indicator.dart';
import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ema_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/hma_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/sma_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/wma_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/zelma_indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';

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
    List<Tick> entries,
    MAOptions options, {
    String id,
    LineStyle style,
  }) : this.fromIndicator(
          CloseValueIndicator(entries),
          id: id,
          options: options,
          style: style,
        );

  /// Initializes
  MASeries.fromIndicator(
    Indicator indicator, {
    String id,
    LineStyle style,
    MAOptions options,
  }) : super(
          indicator,
          id ?? 'SMASeries-period${options.period}-type${options.type}',
          options,
          style: style ?? const LineStyle(thickness: 0.5),
        );

  @override
  SeriesPainter<Series> createPainter() => LinePainter(this);

  @override
  CachedIndicator initializeIndicator() =>
      MASeries.getMAIndicator(inputIndicator, options);

  /// Returns a moving average indicator based on [period] and its [type].
  static CachedIndicator getMAIndicator(
    Indicator indicator,
    MAOptions maOptions,
  ) {
    switch (maOptions.type) {
      case MovingAverageType.exponential:
        return EMAIndicator(indicator, maOptions.period);
      case MovingAverageType.weighted:
        return WMAIndicator(indicator, maOptions.period);
      case MovingAverageType.hull:
        return HMAIndicator(indicator, maOptions.period);
      case MovingAverageType.zeroLag:
        return ZLEMAIndicator(indicator, maOptions.period);
      default:
        return SMAIndicator(indicator, maOptions.period);
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
