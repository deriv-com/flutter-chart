import 'package:deriv_chart/src/logic/indicators/calculations/ma_env/ma_env_shift_typs.dart';

import '../../../../../deriv_chart.dart';
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
