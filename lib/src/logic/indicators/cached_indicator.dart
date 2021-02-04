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
        lastResultIndex = 0,
        super(entries);

  /// Initializes from another [Indicator]
  CachedIndicator.fromIndicator(Indicator indicator) : this(indicator.entries);

  /// Index of the last result that is calculated.
  int lastResultIndex;

  // TODO(NA): Can be overridden on those indicators that can calculate
  //  results for their entire list at once in a more optimal way.
  /// Calculates indicator's result for all [entries] and caches them.
  void calculateValues() {
    for (int i = 0; i < entries.length; i++) {
      getValue(i);
    }
  }

  /// Copies the result of [other] as its own.
  void copyValuesFrom(covariant CachedIndicator other) {
    results
      ..clear()
      ..addAll(other.results);

    lastResultIndex = other.lastResultIndex;
  }

  /// List of cached result.
  final List<Tick> results;

  @override
  Tick getValue(int index) {
    _growResultsForIndex(index);

    if (results[index] == null) {
      results[index] = calculate(index);
    }

    if (index > lastResultIndex) {
      lastResultIndex = index;
    }

    return results[index];
  }

  /// Grows the results list with null elements to cover the given [index].
  ///
  /// Returns number of elements that have been added to the results list.
  int _growResultsForIndex(int index) {
    final int oldResultsCount = results.length;

    if (index > oldResultsCount - 1) {
      results.addAll(List<Tick>(index - oldResultsCount + 1));
    }

    return results.length - oldResultsCount;
  }

  /// Calculates the value of this indicator for the given [index] without caching it.
  /// 
  /// Returns the result as a [Tick].
  Tick calculate(int index);

  /// Invalidates a calculated indicator value for [index]
  void invalidate(int index) {
    _growResultsForIndex(index);
    results[index] = null;
  }

  /// Recalculates indicator's value for the give [index] and caches it.
  ///
  /// Returns the result as a [Tick].
  Tick refreshValueFor(int index) {
    invalidate(index);
    return getValue(index);
  }
}
