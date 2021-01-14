import 'dart:developer' as dev;

import 'package:deriv_chart/src/models/ohlc.dart';
import 'package:deriv_chart/src/models/tick.dart';

import 'indicator.dart';

/// Calculates and keeps the result of indicator calculation values in [results].
/// And decides when to calculate indicator's value for an index.
// TODO(Ramin): Later if we require a level of caching can be added here. Right now it calculates indicator for the entire list.
abstract class CachedIndicator extends Indicator {
  /// Initializes
  CachedIndicator(List<OHLC> entries)
      : results = List<Tick>.generate(entries.length, (_) => null),
        super(entries);

  /// Initializes from another [Indicator]
  CachedIndicator.fromIndicator(Indicator indicator)
      : this(indicator.entries);

  /// Makes sure indicator's result for all [entries] are cached.
  void calculateValues() {
    for (int i = 0; i < entries.length; i++) {
      getValue(i);
    }
  }

  /// Copies the result of [other] as its own.
  void copyValuesFrom(covariant CachedIndicator other) => results
    ..clear()
    ..addAll(other.results);

  /// List of cached result.
  final List<Tick> results;

  @override
  Tick getValue(int index) {
    _growResultsForIndex(index);

    if (results[index] == null) {
      results[index] = calculate(index);
    }

    return results[index];
  }

  void _growResultsForIndex(int index) {
    if (index > results.length - 1) {
      results.addAll(List<Tick>(index - results.length + 1));
    }
  }

  /// Calculates the value of this indicator for the given [index]
  Tick calculate(int index);

  /// Invalidates a calculated indicator value for [index]
  void invalidate(int index) {
    _growResultsForIndex(index);

    results[index] = null;
  }
}
