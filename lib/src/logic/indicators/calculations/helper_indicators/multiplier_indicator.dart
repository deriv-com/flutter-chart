import 'package:deriv_chart/src/models/tick.dart';

import '../../abstract_indicator.dart';

/// A helper indicator to multiply another indicator values by a [coefficient].
class MultiplierIndicator extends AbstractIndicator {
  /// Initializes
  MultiplierIndicator(this.indicator, this.coefficient)
      : super(indicator.entries);

  /// Indicator
  final AbstractIndicator indicator;

  /// Coefficient
  final double coefficient;

  @override
  Tick getValue(int index) => Tick(
        epoch: getEpochOfIndex(index),
        quote: indicator.getValue(index).quote * coefficient,
      );
}
