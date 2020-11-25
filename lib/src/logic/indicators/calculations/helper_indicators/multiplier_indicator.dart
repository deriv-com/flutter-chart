import 'package:deriv_chart/src/models/tick.dart';

import '../../cached_indicator.dart';
import '../../indicator.dart';

/// A helper indicator to multiply another indicator values by a [coefficient].
class MultiplierIndicator extends CachedIndicator {
  /// Initializes
  MultiplierIndicator(this.indicator, this.coefficient)
      : super.fromIndicator(indicator);

  /// Indicator
  final Indicator indicator;

  /// Coefficient
  final double coefficient;

  @override
  Tick calculate(int index) => Tick(
        epoch: getEpochOfIndex(index),
        quote: indicator.getValue(index).quote * coefficient,
      );
}
