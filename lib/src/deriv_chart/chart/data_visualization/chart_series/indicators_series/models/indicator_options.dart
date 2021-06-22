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
  const MAOptions({
    this.period = 20,
    this.type = MovingAverageType.simple,
  });

  /// The average of this number of past data which will be calculated as MA value.
  final int period;

  /// Moving average type
  final MovingAverageType type;

  @override
  List<Object> get props => <Object>[period, type];
}
