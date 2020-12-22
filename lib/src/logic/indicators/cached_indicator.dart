import 'package:deriv_chart/src/models/tick.dart';

import 'abstract_indicator.dart';

/// Calculates and keeps the result of indicator calculation values in [results].
/// Decides for how many elements in the [entries] list indicator values should be calculated.
// TODO(Ramin): Later if we require a level of caching can be added here. Right now it calculates indicator for the entire list.
abstract class CachedIndicator<T extends Tick> extends AbstractIndicator<T> {
  /// Initializes
  CachedIndicator(List<T> entries)
      : results = List<Tick>.generate(entries.length, (_) => null),
        super(entries);

  /// Initializes from another [AbstractIndicator]
  CachedIndicator.fromIndicator(AbstractIndicator<T> indicator)
      : this(indicator.entries);

  void calculateValues() {
    for (int i = 0; i < entries.length; i++) {
      getValue(i);
    }
  }

  void copyValuesFrom(covariant CachedIndicator<T> other) => results
    ..clear()
    ..addAll(other.results);

  /// List of cached result.
  final List<Tick> results;

  @override
  Tick getValue(int index) {
    _growResultsForIndex(index);

    if (results[index] == null) {
      results[index] = calculate(index);
      // print('Calculating $runtimeType for $index  ${DateTime.now()}');
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
