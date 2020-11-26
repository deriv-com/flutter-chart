import 'package:deriv_chart/src/logic/indicators/cached_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ema_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/quote_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/hma_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/sma_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/wma_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/zelma_indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';

import '../line_series/line_series.dart';

/// A series which shows Moving Average data calculated from [entries].
class MASeries extends LineSeries {
  /// Initializes
  ///
  /// [period] is the average of this number of past data which will be calculated as MA value
  /// [type] The type of moving average.
  MASeries(
    List<Tick> entries, {
    String id,
    LineStyle style,
    int period = 15,
    MovingAverageType type = MovingAverageType.simple,
  }) : super(
          _getMAIndicator(entries, period, type).results,
          id: id ?? 'SMASeries-period$period-type$type',
          style: style ?? const LineStyle(thickness: 0.5),
        );

  static CachedIndicator _getMAIndicator(
    List<Tick> entries,
    int period,
    MovingAverageType type,
  ) {
    switch (type) {
      case MovingAverageType.exponential:
        return EMAIndicator(QuoteIndicator(entries), period);
      case MovingAverageType.weighted:
        return WMAIndicator(QuoteIndicator(entries), period);
      case MovingAverageType.hull:
        return HMAIndicator(QuoteIndicator(entries), period);
      case MovingAverageType.zeroLag:
        return ZLEMAIndicator(QuoteIndicator(entries), period);
      default:
        return SMAIndicator(QuoteIndicator(entries), period);
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
