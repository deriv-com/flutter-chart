import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/quote_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/sma_indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';

import '../line_series/line_series.dart';

/// A series which shows Moving Average data calculated from [entries]
class SMASeries extends LineSeries {
  /// Initializes
  ///
  /// [period] is the average of this number of past data which will be calculated as MA value
  SMASeries(
    List<Tick> entries, {
    String id,
    LineStyle style,
    this.period = 15,
  }) : super(
          SMAIndicator(QuoteIndicator(entries), period).results,
          id: id ?? 'MASeries-Period$period',
          style: style ?? const LineStyle(thickness: 0.5, hasArea: false),
        );

  /// Moving average period
  final int period;
}
