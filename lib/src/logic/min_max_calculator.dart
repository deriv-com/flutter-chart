import 'dart:collection';

import 'package:deriv_chart/src/models/tick.dart';

/// Accepts a list of entries sorted by time and calculates min/max values for that list.
/// Reuses previous work done when visible entries are updated.
///
/// Keep one instance for each unique `Series` or list of entries where visible entries change over time.
class MinMaxCalculator {
  /// Instantiate min/max calculator with [minValueOf] and [maxValueOf] functions
  /// that return min/max respectively of the given entry.
  ///
  /// [epochOf] Returns the epoch of entry
  MinMaxCalculator(
    this.minValueOf,
    this.maxValueOf, {
    int Function(Tick) epochOf,
  }) : _epochOf = epochOf ?? ((Tick tick) => tick.epoch);

  /// List of current entries from which min/max is calculated.
  List<Tick> _visibleEntries;

  /// Returns min of entry.
  final double Function(Tick) minValueOf;

  /// Returns max of entry.
  final double Function(Tick) maxValueOf;

  final int Function(Tick) _epochOf;

  /// A map sorted by key that keeps track of number of occurences of `min` and `max` values for all `_visibleEntries`.
  final SplayTreeMap<double, int> _visibleEntriesCount =
      SplayTreeMap<double, int>();

  /// Minimum value of current visible entries.
  double get min => _visibleEntriesCount?.firstKey() ?? double.nan;

  /// Maximum value of current visible entries.
  double get max => _visibleEntriesCount?.lastKey() ?? double.nan;

  /// Efficiently calculates new min/max by comparing previous visible entries and [newVisibleEntries].
  void calculate(List<Tick> newVisibleEntries) {
    if (newVisibleEntries == null || newVisibleEntries.isEmpty) {
      _visibleEntriesCount.clear();
    } else if (_visibleEntries == null ||
        _visibleEntries.isEmpty ||
        _noOverlap(_visibleEntries, newVisibleEntries)) {
      _visibleEntriesCount.clear();

      for (final Tick entry in newVisibleEntries) {
        _incrementCount(minValueOf(entry));
        _incrementCount(maxValueOf(entry));
      }
    } else {
      final List<Tick> addedEntries = <Tick>[];
      final List<Tick> removedEntries = <Tick>[];

      // Compare and find what entries got removed/added by checking epochs.
      if (_epochOf(_visibleEntries.first) < _epochOf(newVisibleEntries.first)) {
        removedEntries.addAll(
          _visibleEntries.takeWhile((Tick entry) =>
              _epochOf(entry) < _epochOf(newVisibleEntries.first)),
        );
      } else {
        addedEntries.addAll(
          newVisibleEntries.takeWhile((Tick entry) =>
              _epochOf(entry) < _epochOf(_visibleEntries.first)),
        );
      }

      if (_epochOf(_visibleEntries.last) > _epochOf(newVisibleEntries.last)) {
        removedEntries.addAll(
          _visibleEntries.reversed.takeWhile((Tick entry) =>
              _epochOf(entry) > _epochOf(newVisibleEntries.last)),
        );
      } else {
        addedEntries.addAll(
          newVisibleEntries.reversed.takeWhile(
              (Tick entry) => _epochOf(entry) > _epochOf(_visibleEntries.last)),
        );
      }

      for (final Tick entry in addedEntries) {
        _incrementCount(minValueOf(entry));
        _incrementCount(maxValueOf(entry));
      }

      for (final Tick entry in removedEntries) {
        _decrementCount(minValueOf(entry));
        _decrementCount(maxValueOf(entry));
      }
    }

    _visibleEntries = newVisibleEntries;
  }

  void _incrementCount(double value) {
    _visibleEntriesCount.putIfAbsent(value, () => 0);
    _visibleEntriesCount[value]++;
  }

  void _decrementCount(double value) {
    _visibleEntriesCount[value]--;
    if (_visibleEntriesCount[value] == 0) {
      _visibleEntriesCount.remove(value);
    }
  }

  /// Whether there are no shared entries between two sorted lists.
  bool _noOverlap(
    List<Tick> listA,
    List<Tick> listB,
  ) {
    if (listA.isEmpty || listB.isEmpty) {
      return true;
    }
    // Option A: All entries in ListA are behind entries in ListB.
    if (_epochOf(listA.last) < _epochOf(listB.first)) {
      return true;
    }
    // Option B: All entries in ListA are in front of entries in ListB.
    if (_epochOf(listA.first) > _epochOf(listB.last)) {
      return true;
    }
    return false;
  }
}
