import 'package:deriv_chart/src/models/tick.dart';

import 'abstract_indicator.dart';

/// Calculates and keeps the result of indicator calculation values in [results].
/// Decides for how many elements in the [entries] list indicator values should be calculated.
// TODO(Ramin): Later if we require a level of caching can be added here. Right now it calculates indicator for the entire list.
abstract class CachedIndicator<T extends Tick> extends AbstractIndicator<T> {
  /// Initializes
  CachedIndicator(List<T> entries)
      : results = List<Tick>(entries.length),
        super(entries) {
    _calculateIndicatorValues();
  }

  /// Initializes from another [AbstractIndicator]
  CachedIndicator.fromIndicator(AbstractIndicator<T> indicator)
      : this(indicator.entries);

  void _calculateIndicatorValues() {
    for (int i = 0; i < entries.length; i++) {
      getValue(i);
    }
  }

  /// List of cached result.
  final List<Tick> results;

  @override
  Tick getValue(int index) {
    if (results[index] == null) {
      results[index] = calculate(index);
    }

    return results[index];
  }

  /// Calculates the value of this indicator for the given [index]
  Tick calculate(int index);
}
