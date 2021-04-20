import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/indicator_options.dart';

/// Commodity Channel Index indicator options class.
class CCIOptions extends IndicatorOptions {
  /// Initializes
  const CCIOptions(this.period);

  /// The period of CCI.
  final int period;

  @override
  List<Object> get props => <Object>[period];
}
