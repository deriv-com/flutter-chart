import 'package:deriv_chart/src/models/tick.dart';

import '../../indicator.dart';
import '../cached_indicator.dart';

class MultiplierIndicator extends CachedIndicator {
  final Indicator indicator;
  final double coefficient;

  MultiplierIndicator(this.indicator, this.coefficient)
      : super.fromIndicator(indicator);

  @override
  Tick calculate(int index) => Tick(
        epoch: getEpochOfIndex(index),
        quote: indicator.getValue(index).quote * coefficient,
      );
}
