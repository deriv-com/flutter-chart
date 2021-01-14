import 'package:deriv_chart/src/models/tick.dart';

import '../../indicator.dart';

/// Difference values between two indicators
class DifferenceIndicator extends Indicator {
  /// Initializes
  ///
  /// (first minus second)
  DifferenceIndicator(this.first, this.second) : super(first.entries) {
    // TODO: check if first indicator is equal to second one
  }

  /// First indicator
  final Indicator first;

  /// Second indicator
  final Indicator second;

  @override
  Tick getValue(int index) => Tick(
        epoch: getEpochOfIndex(index),
        quote: first.getValue(index).quote - (second.getValue(index).quote),
      );
}
