import 'dart:collection';

/// Accepts a list of entries sorted by time and calculates min/max values for that list.
/// Reuses previous work done when visible entries are updated.
///
/// Keep one instance for each unique `Series` or list of entries where visible entries change over time.
class MinMaxCalculator<T extends MinMaxCalculatorEntry> {
  /// List of current entries from which min/max is calculated.
  List<T> _visibleEntries;

  /// A map that keeps track of number of occurences of `min` and `max` values for all `_visibleEntries`.
  final SplayTreeMap<double, int> _visibleEntriesCount =
      SplayTreeMap<double, int>();

  /// Minimum value of current visible entries.
  double get min => _visibleEntriesCount?.firstKey() ?? double.nan;

  /// Maximum value of current visible entries.
  double get max => _visibleEntriesCount?.lastKey() ?? double.nan;

  /// Updates a list of visible entries and efficiently recalculates new min/max.
  void updateVisibleEntries(List<T> newVisibleEntries) {
    if (_visibleEntries == null) {
      _visibleEntries = newVisibleEntries;

      for (final MinMaxCalculatorEntry entry in _visibleEntries) {
        // Initialize keys if absent.
        _visibleEntriesCount
          ..putIfAbsent(entry.min, () => 0)
          ..putIfAbsent(entry.max, () => 0);

        _visibleEntriesCount[entry.min]++;
        _visibleEntriesCount[entry.max]++;
      }
    } else {
      // TODO: Reuse previous work.
    }
  }
}

/// Interface that should be implemented by all entries to `MinMaxCalculator`.
abstract class MinMaxCalculatorEntry {
  /// Epoch time of this entry.
  int epoch;

  /// Minumum value of this entry.
  double min;

  /// Maximum value of this entry.
  double max;
}
