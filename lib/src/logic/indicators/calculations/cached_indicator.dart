import 'package:deriv_chart/src/models/tick.dart';

import 'abstract_indicator.dart';

/// Calculates and keeps the result of indicator calculation values in [results].
// TODO(Ramin): Later if required a level of caching can be added here. Right now it calculates indicator for the entire entries.
abstract class CachedIndicator<T extends Tick> extends AbstractIndicator<T> {
  CachedIndicator(List<T> entries)
      : results = List<Tick>(entries.length),
        super(entries) {
    _calculateValues();
  }

  /// Initializes from another [AbstractIndicator]
  CachedIndicator.fromIndicator(AbstractIndicator indicator)
      : this(indicator.entries);

  void _calculateValues() {
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
