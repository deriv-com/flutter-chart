import 'package:deriv_chart/src/models/tick.dart';

import '../../indicator.dart';

/// Half of difference between two indicator values.
class HalfDifferenceIndicator extends Indicator {
  /// Initializes
  HalfDifferenceIndicator(this.first, this.second) : super(first.entries);

  /// First indicator.
  final Indicator first;

  /// Second indicator.
  final Indicator second;

  @override
  Tick getValue(int index) => Tick(
        epoch: getEpochOfIndex(index),
        quote: (first.getValue(index).quote - second.getValue(index).quote) / 2,
      );
}
