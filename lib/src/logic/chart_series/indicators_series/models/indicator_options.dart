import 'package:equatable/equatable.dart';

import '../ma_series.dart';

/// Base class of indicator options
///
/// Is used to detect changes in the options of an indicator to whether recalculate
/// its values again or use it's old values.
abstract class IndicatorOptions extends Equatable {}

/// Moving Average indicator options
class MAOptions extends IndicatorOptions {
  /// Initializes
  MAOptions(this.period, {this.type = MovingAverageType.simple});

  /// Period
  final int period;

  /// Moving average type
  final MovingAverageType type;

  @override
  List<Object> get props => <Object>[period, type];
}
