import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/indicator_options.dart';

/// Aroon indicator options.
class AroonOptions extends IndicatorOptions {
  /// Initializes an Aroon indicator options.
  const AroonOptions({this.period = 14});

  /// The period to calculate aroon Indicator on.
  final int period;

  @override
  List<Object> get props => <Object>[period];
}
