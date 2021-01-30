import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import '../line_series/line_series.dart';

/// A series which shows Moving Average data calculated from [entries].
class MASeries extends LineSeries {
  /// Initializes a series which shows shows moving Average data calculated from [entries].
  ///
  /// [period] is the average of this number of past data which will be calculated as MA value
  /// [type] The type of moving average.
  MASeries(
    IndicatorInput indicatorInput, {
    String id,
    LineStyle style,
    int period = 15,
    MovingAverageType type = MovingAverageType.simple,
  }) : this.fromIndicator(
          CloseValueIndicator<Tick>(indicatorInput),
          id: id,
          style: style,
          period: period,
          type: type,
        );

  /// Initializes
  MASeries.fromIndicator(
    Indicator<Tick> indicator, {
    String id,
    LineStyle style,
    int period = 15,
    MovingAverageType type = MovingAverageType.simple,
  }) : super(
          getMAIndicator(indicator, period, type).results,
          id: id ?? 'SMASeries-period$period-type$type',
          style: style ?? const LineStyle(thickness: 0.5),
        );

  /// Creates Moving Average indicator.
  static CachedIndicator<Tick> getMAIndicator(
    Indicator<Tick> indicator,
    int period,
    MovingAverageType type,
  ) {
    switch (type) {
      case MovingAverageType.exponential:
        return EMAIndicator<Tick>(indicator, period);
      case MovingAverageType.weighted:
        return WMAIndicator<Tick>(indicator, period);
      case MovingAverageType.hull:
        return HMAIndicator<Tick>(indicator, period);
      case MovingAverageType.zeroLag:
        return ZLEMAIndicator<Tick>(indicator, period);
      default:
        return SMAIndicator<Tick>(indicator, period);
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
