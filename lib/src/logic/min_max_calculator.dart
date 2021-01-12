import 'dart:collection';

/// Accepts a list of entries sorted by time and calculates min/max values for that list.
/// Reuses previous work done when visible entries are updated.
///
/// Keep one instance for each unique `Series` or list of entries where visible entries change over time.
class MinMaxCalculator<T extends MinMaxCalculatorEntry> {
  /// List of current entries from which min/max is calculated.
  List<T> _visibleEntries;

  /// A map sorted by key that keeps track of number of occurences of `min` and `max` values for all `_visibleEntries`.
  final SplayTreeMap<double, int> _visibleEntriesCount =
      SplayTreeMap<double, int>();

  /// Minimum value of current visible entries.
  double get min => _visibleEntriesCount?.firstKey() ?? double.nan;

  /// Maximum value of current visible entries.
  double get max => _visibleEntriesCount?.lastKey() ?? double.nan;

  /// Updates a list of visible entries and efficiently recalculates new min/max.
  void updateVisibleEntries(List<T> newVisibleEntries) {
    if (newVisibleEntries == null || newVisibleEntries.isEmpty) {
      _visibleEntriesCount.clear();
    } else if (_visibleEntries == null ||
        _visibleEntries.isEmpty ||
        _noOverlap(_visibleEntries, newVisibleEntries)) {
      _visibleEntries = newVisibleEntries;
      _visibleEntriesCount.clear();

      for (final MinMaxCalculatorEntry entry in _visibleEntries) {
        // Initialize keys if absent.
        _visibleEntriesCount
          ..putIfAbsent(entry.min, () => 0)
          ..putIfAbsent(entry.max, () => 0);

        _visibleEntriesCount[entry.min]++;
        _visibleEntriesCount[entry.max]++;
      }
    } else {
      final List<MinMaxCalculatorEntry> addedEntries =
          <MinMaxCalculatorEntry>[];
      final List<MinMaxCalculatorEntry> removedEntries =
          <MinMaxCalculatorEntry>[];

      // Compare and find what entries got removed/added by checking epochs.
      if (_visibleEntries.first.epoch < newVisibleEntries.first.epoch) {
        removedEntries.addAll(
          _visibleEntries.takeWhile((MinMaxCalculatorEntry entry) =>
              entry.epoch < newVisibleEntries.first.epoch),
        );
      } else {
        addedEntries.addAll(
          newVisibleEntries.takeWhile((MinMaxCalculatorEntry entry) =>
              entry.epoch > _visibleEntries.first.epoch),
        );
      }

      if (_visibleEntries.last.epoch > newVisibleEntries.last.epoch) {
        removedEntries.addAll(
          _visibleEntries.reversed.takeWhile((MinMaxCalculatorEntry entry) =>
              entry.epoch > newVisibleEntries.last.epoch),
        );
      } else {
        addedEntries.addAll(
          newVisibleEntries.reversed.takeWhile((MinMaxCalculatorEntry entry) =>
              entry.epoch < _visibleEntries.last.epoch),
        );
      }

      for (final MinMaxCalculatorEntry entry in addedEntries) {
        // Initialize keys if absent.
        _visibleEntriesCount
          ..putIfAbsent(entry.min, () => 0)
          ..putIfAbsent(entry.max, () => 0);

        _visibleEntriesCount[entry.min]++;
        _visibleEntriesCount[entry.max]++;
      }

      for (final MinMaxCalculatorEntry entry in removedEntries) {
        _visibleEntriesCount[entry.min]--;
        if (_visibleEntriesCount[entry.min] == 0) {
          _visibleEntriesCount.remove(entry.min);
        }

        _visibleEntriesCount[entry.max]--;
        if (_visibleEntriesCount[entry.max] == 0) {
          _visibleEntriesCount.remove(entry.max);
        }
      }
    }
  }

  /// Whether there are no shared entries.
  bool _noOverlap(
    List<MinMaxCalculatorEntry> listA,
    List<MinMaxCalculatorEntry> listB,
  ) {
    if (listA.isEmpty || listB.isEmpty) {
      return true;
    }
    // Option A: All entries in ListA are behind entries in ListB.
    if (listA.last.epoch < listB.first.epoch) {
      return true;
    }
    // Option B: All entries in ListA are in front of entries in ListB.
    if (listA.first.epoch > listB.last.epoch) {
      return true;
    }
    return false;
  }
}

/// Interface that should be implemented by all entries to `MinMaxCalculator`.
abstract class MinMaxCalculatorEntry {
  /// Epoch time of this entry.
  int get epoch;

  /// Minumum value of this entry.
  double get min;

  /// Maximum value of this entry.
  double get max;
}
