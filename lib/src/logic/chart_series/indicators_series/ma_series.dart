import 'package:deriv_chart/src/logic/indicators/indicators.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';

import '../line_series/line_series.dart';

/// A series which shows moving Average data calculated from [entries].
class MASeries extends LineSeries {
  /// Initializes a series which shows shows moving Average data calculated from [entries].
  ///
  /// [period] is the average of this number of past data which will be calculated as MA value.
  MASeries(
    List<Tick> entries, {
    String id,
    LineStyle style,
    this.period = 15,
  }) : super(
          MovingAverage.movingAverage(entries, period),
          id: id ?? 'MASeries-Period$period',
          style: style ?? LineStyle(thickness: 0.5, hasArea: false),
        );

  /// Moving average period.
  final int period;
}
