/// Accepts a list of entries sorted by time and calculates min/max values for that list.
/// Reuses work done when a new list is supplied.
/// TODO: Use OHLC interface?
///
/// Keep one instance for each unique `Series` or list of entries where visible entries change over time.
class MinMaxCalculator<T implements MinMaxCalculatorEntry> {
  /// Creates and calculates min/max immediately.
  MinMaxCalculator(List<T> visibleEntries) : _visibleEntries = visibleEntries;

  List<T> _visibleEntries;

  /// Minimum value of current visible entries.
  double get min;

  /// Maximum value of current visible entries.
  double get max;

  /// Updates a list of entries and efficiently recalculates min/max.
  void updateEntries(List<T> newVisibleEntries) {}
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
