/// Accepts a list of entries and calculates min/max values for that list.
/// Reuses work done when a new list is supplied.
/// TODO: Use OHLC interface?
///
/// Keep one instance for each unique `Series` or list of data with a sliding window.
class MinMaxCalculator<T extends Tick> {
  /// Creates and calculates min/max immediately.
  MinMaxCalculator(List<T> entries) : _entries = entries;

  List<T> _entries;

  double get min;

  double get max;

  /// Updates a list of entries and efficiently recalculates min/max.
  void updateEntries(List<T> newEntries) {}
}
