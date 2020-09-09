import 'package:deriv_chart/src/logic/indicators/indicators.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';

import 'line_series.dart';

/// A series which shows Moving Average data calculated from [entries]
class MASeries extends LineSeries {
  /// Initializes
  ///
  /// [period] average of this number of past data will be calculated for every entry
  MASeries(
    List<Tick> entries,
    String id, {
    LineStyle style,
    this.period = 15,
  }) : super(MovingAverage.movingAverage(entries, period), id, style: style);

  /// Moving average period
  final int period;
}
