import 'package:equatable/equatable.dart';

import '../ma_series.dart';

/// Base class of indicator options
///
/// Is used to detect changes in the options of an indicator to whether
/// recalculate its values again or use it's old values.
/// For an indicator any option which by changing it, the result of that
/// indicator would need to be calculated again should be in its option class.
abstract class IndicatorOptions extends Equatable {
  /// Initializes
  ///
  /// Provides const constructor for sub-classes
  const IndicatorOptions({
    this.showLastIndicator = false,
    this.pipSize = 4,
  });

  /// Whether to show last indicator or not.
  final bool showLastIndicator;

  /// Number of digits after decimal point in price.
  final int pipSize;
}

/// Moving Average indicator options
class MAOptions extends IndicatorOptions {
  /// Initializes
  const MAOptions({
    this.period = 20,
    this.type = MovingAverageType.simple,
    bool showLastIndicator = false,
    int pipSize = 4,
  }) : super(showLastIndicator: showLastIndicator, pipSize: pipSize);

  /// The average of this number of past data which will be calculated as
  /// MA value.
  final int period;

  /// Moving average type
  final MovingAverageType type;

  @override
  List<Object> get props => <Object>[period, type];
}
