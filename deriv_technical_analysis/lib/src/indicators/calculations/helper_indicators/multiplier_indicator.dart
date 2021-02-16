import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import '../../indicator.dart';

/// A helper indicator to multiply another indicator values by a [coefficient].
class MultiplierIndicator<T extends IndicatorResult> extends Indicator<T> {
  /// Initializes
  MultiplierIndicator(this.indicator, this.coefficient)
      : super(indicator.input);

  /// Indicator
  final Indicator<T> indicator;

  /// Coefficient
  final double coefficient;

  @override
  T getValue(int index) => createResult(
        index: index,
        quote: indicator.getValue(index).quote * coefficient,
      );
}
