import 'package:deriv_chart/src/models/candle.dart';

import 'abstract_indicator.dart';

/// Handling a level of caching
abstract class CachedIndicator extends AbstractIndicator {
  CachedIndicator(List<Candle> candles) : super(candles) {
    for (int i = 0; i < candles.length; i++) {
      results.add(getValue(i));
    }
  }

  CachedIndicator.fromIndicator(AbstractIndicator indicator)
      : this(indicator.candles);

  /// List of cached result.
  final List<double> results = <double>[];

  @override
  // TODO(Ramin): Add caching logic if we it someday.
  double getValue(int index) => calculate(index);

  /// Calculates the value of this indicator for the give [index]
  double calculate(int index);
}
