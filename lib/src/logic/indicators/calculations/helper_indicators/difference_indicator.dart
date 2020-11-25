import 'package:deriv_chart/src/models/tick.dart';

import '../../abstract_indicator.dart';

/// Difference values between two indicators
class DifferenceIndicator extends AbstractIndicator {
  /// First indicator
  final AbstractIndicator first;

  /// Second indicator
  final AbstractIndicator second;

  /// (first minus second)
  DifferenceIndicator(this.first, this.second) : super(first.entries) {
    // TODO: check if first indicator is equal to second one
  }

  @override
  Tick getValue(int index) => Tick(
        epoch: getEpochOfIndex(index),
        quote: first.getValue(index).quote - (second.getValue(index).quote),
      );
}
