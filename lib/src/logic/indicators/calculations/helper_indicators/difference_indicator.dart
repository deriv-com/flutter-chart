import 'package:deriv_chart/src/models/tick.dart';

import '../../cached_indicator.dart';
import '../../indicator.dart';

class DifferenceIndicator extends CachedIndicator {
  final Indicator first;
  final Indicator second;

  /// (first minus second)
  DifferenceIndicator(this.first, this.second) : super.fromIndicator(first) {
    // TODO: check if first indicator is equal to second one
  }

  @override
  Tick calculate(int index) => Tick(
        epoch: getEpochOfIndex(index),
        quote: first.getValue(index).quote - (second.getValue(index).quote),
      );
}
