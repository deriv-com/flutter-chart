import 'package:deriv_chart/src/logic/indicators/calculations/ma_env/ma_env_shift_typs.dart';
import 'package:equatable/equatable.dart';

import '../ma_series.dart';

/// Base class of indicator options
///
/// Is used to detect changes in the options of an indicator to whether recalculate
/// its values again or use it's old values.
abstract class IndicatorOptions extends Equatable {
  /// Initializes
  ///
  /// Provides const constructor for sub-classes
  const IndicatorOptions();
}

/// Moving Average indicator options
class MAOptions extends IndicatorOptions {
  /// Initializes
  const MAOptions({this.period = 20, this.type = MovingAverageType.simple});

  /// Period
  final int period;

  /// Moving average type
  final MovingAverageType type;

  @override
  List<Object> get props => <Object>[period, type];
}

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
