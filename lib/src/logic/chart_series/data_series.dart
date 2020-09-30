import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/chart_paiting_style.dart';
import 'package:flutter/material.dart';

/// Series with only a single list of data to show.
abstract class DataSeries<T extends Tick> extends Series {
  /// Initializes
  ///
  /// [entries] is the list of data to show.
  DataSeries(
    this.entries,
    String id, {
    ChartPaintingStyle style,
  }) : super(id, style: style);

  /// Series entries
  final List<T> entries;

  List<T> _visibleEntries = <T>[];

  /// Series visible entries
  List<T> get visibleEntries => _visibleEntries;

  T _prevLastEntry;

  /// A reference to the last entry from series previous [entries] before update
  T get prevLastEntry => _prevLastEntry;

  /// Updates visible entries for this Series.
  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    if (entries.isEmpty) {
      return;
    }

    final int startIndex = _searchLowerIndex(leftEpoch);
    final int endIndex = _searchUpperIndex(rightEpoch);

    _visibleEntries = startIndex == -1 || endIndex == -1
        ? <T>[]
        : entries.sublist(startIndex, endIndex);
  }

  /// Minimum value in [t]
  double minValueOf(T t);

  /// Maximum value in [t]
  double maxValueOf(T t);

  /// Gets min and max quotes after updating [visibleEntries] as an array with two elements [min, max].
  ///
  /// Sub-classes can override this method if they calculate [minValue] & [maxValue] differently.
  @override
  List<double> recalculateMinMax() {
    if (visibleEntries.isNotEmpty) {
      double min = minValueOf(visibleEntries[0]);
      double max = maxValueOf(visibleEntries[0]);

      for (int i = 1; i < visibleEntries.length; i++) {
        final T t = visibleEntries[i];

        if (maxValueOf(t) > max) {
          max = maxValueOf(t);
        } else if (minValueOf(t) < min) {
          min = minValueOf(t);
        }
      }

      return <double>[min, max];
    } else {
      return <double>[double.nan, double.nan];
    }
  }

  int _searchLowerIndex(int leftEpoch) {
    if (leftEpoch < entries[0].epoch) {
      return 0;
    } else if (leftEpoch > entries[entries.length - 1].epoch) {
      return -1;
    }

    final int closest = _findClosestIndex(leftEpoch);

    final int index = closest <= leftEpoch
        ? closest
        : closest - 1 < 0 ? closest : closest - 1;
    return index - 1 < 0 ? index : index - 1;
  }

  int _searchUpperIndex(int rightEpoch) {
    if (rightEpoch < entries[0].epoch) {
      return -1;
    } else if (rightEpoch > entries[entries.length - 1].epoch) {
      return entries.length;
    }

    final int closest = _findClosestIndex(rightEpoch);

    final int index = closest >= rightEpoch
        ? closest
        : (closest + 1 > entries.length ? closest : closest + 1);
    return index == entries.length ? index : index + 1;
  }

  // Binary search to find closest index to the [epoch].
  int _findClosestIndex(int epoch) {
    int lo = 0;
    int hi = entries.length - 1;

    while (lo <= hi) {
      final int mid = (hi + lo) ~/ 2;

      if (epoch < entries[mid].epoch) {
        hi = mid - 1;
      } else if (epoch > entries[mid].epoch) {
        lo = mid + 1;
      } else {
        return mid;
      }
    }

    return (entries[lo].epoch - epoch) < (epoch - entries[hi].epoch) ? lo : hi;
  }

  /// Will be called by the chart when it was updated.
  @override
  void didUpdate(ChartData oldData) {
    final DataSeries<T> oldSeries = oldData;
    if (oldSeries.entries.isNotEmpty) {
      _prevLastEntry = oldSeries.entries.last;
    }
  }

  /// Each sub-class should implement and return appropriate cross-hair text based on its own requirements
  Widget getCrossHairInfo(T crossHairTick, int pipSize);
}
