import 'dart:collection';

/// Accepts a list of entries sorted by time and calculates min/max values for that list.
/// Reuses previous work done when visible entries are updated.
///
/// Keep one instance for each unique `Series` or list of entries where visible entries change over time.
class MinMaxCalculator<T implements MinMaxCalculatorEntry> {
  /// Creates a min/max calculator for entries of given type.
  MinMaxCalculator<T>();

  /// List of current entries from which min/max is calculated.
  List<T> _visibleEntries;

  /// A map that keeps track of number of occurences of `min` and `max` values for all `_visibleEntries`.
  SplayTreeMap<double, int> _visibleEntriesCount;

  /// Minimum value of current visible entries.
  double get min;

  /// Maximum value of current visible entries.
  double get max;

  /// Updates a list of visible entries and efficiently recalculates new min/max.
  void updateVisibleEntries(List<T> newVisibleEntries) {
    if (_visibleEntries == null) {
      _visibleEntries = newVisibleEntries;

      _visibleEntriesCount = SplayTreeMap;
      
      for (final MinMaxCalculatorEntry entry in _visibleEntries) {
        
      }
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
