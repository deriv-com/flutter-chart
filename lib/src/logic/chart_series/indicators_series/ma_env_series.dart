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

import '../../../../deriv_chart.dart';
import '../line_series/line_series.dart';

/// A series which shows Moving Average data calculated from [entries].
class MAEnvSeries extends LineSeries {
  /// Initializes a series which shows shows moving Average data calculated from [entries].
  ///
  /// [period] is the average of this number of past data which will be calculated as MA value
  /// [type] The type of moving average.
  MAEnvSeries(
    List<Tick> entries, {
    String id,
    LineStyle style,
    int period = 50,
    int shift = 5,
    ShiftType shiftType = ShiftType.percent,
    MovingAverageType movingAverageType = MovingAverageType.simple,
  }) : this.fromIndicator(
          CloseValueIndicator(entries),
          id: id,
          style: style,
          period: period,
          movingAverageType: movingAverageType,
          shift: shift,
        );

  /// Initializes
  MAEnvSeries.fromIndicator(
    Indicator indicator, {
    String id,
    LineStyle style,
    int period = 50,
    MovingAverageType movingAverageType = MovingAverageType.simple,
    int shift = 5,
    ShiftType shiftType = ShiftType.percent,
  }) : super(
          getMAIndicator(indicator, period, movingAverageType).results,
          id: id ?? 'SMASeries-period$period-type$movingAverageType',
          style: style ?? const LineStyle(thickness: 0.5),
        );

  static CachedIndicator getMAIndicator(
    Indicator indicator,
    int period,
    MovingAverageType movingAverageType,
  ) {
    switch (movingAverageType) {
      case MovingAverageType.exponential:
        return EMAIndicator(indicator, period);
      case MovingAverageType.weighted:
        return WMAIndicator(indicator, period);
      case MovingAverageType.hull:
        return HMAIndicator(indicator, period);
      case MovingAverageType.zeroLag:
        return ZLEMAIndicator(indicator, period);
      default:
        return SMAIndicator(indicator, period);
    }
  }
}

/// Supported types of shift.
enum ShiftType {
  /// Percent
  percent,

  /// Point
  point,
}
