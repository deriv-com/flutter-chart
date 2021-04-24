// @dart=2.9

import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import '../ma_series.dart';
import 'indicator_options.dart';

/// Moving Average Envelope indicator options.
class MAEnvOptions extends MAOptions {
  /// Initializes
  const MAEnvOptions({
    this.shift = 5,
    this.shiftType,
    int period,
    MovingAverageType movingAverageType,
  }) : super(period: period, type: movingAverageType);

  /// Shift value
  final double shift;

  /// Shift type could be Percent or Point
  final ShiftType shiftType;

  @override
  List<Object> get props => super.props..add(shift)..add(shiftType);
}
