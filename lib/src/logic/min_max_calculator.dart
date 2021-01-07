/// Accepts a list of entries and calculates min/max values for that list.
/// Reuses work done when a new list is supplied.
/// TODO: Use OHLC interface?
///
/// Keep one instance for each unique `Series` or list of entries where visible entries change over time.
class MinMaxCalculator<T extends Tick> {
  /// Creates and calculates min/max immediately.
  MinMaxCalculator(List<T> visibleEntries) : _visibleEntries = visibleEntries;

  List<T> _visibleEntries;

  /// Min value of current visible entries.
  double get min;

  /// Max value of current visible entries.
  double get max;

  /// Updates a list of entries and efficiently recalculates min/max.
  void updateEntries(List<T> newVisibleEntries) {}
}
