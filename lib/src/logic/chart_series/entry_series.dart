import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/chart_object.dart';
import 'package:deriv_chart/src/theme/painting_styles/chart_paiting_style.dart';

/// Series with entries of type [ChartObject]
abstract class EntrySeries<T extends ChartObject> extends Series {
  /// Initializes
  ///
  /// [entries] is the list of [ChartObject] to show.
  EntrySeries(
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

    // TODO(ramin): A shared algorithm for finding visible entries for a list of chart objects
    // Candles, Ticks, Markers, and maybe barrier all will be a type of ChartObject.
    // Temporarily using rightEpoch of ChartObject. Later that shared algorithm will take both rightEpoch and leftEpoch into account.
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
    if (leftEpoch < entries[0].rightEpoch) {
      return 0;
    } else if (leftEpoch > entries[entries.length - 1].rightEpoch) {
      return -1;
    }

    final int closest = _findClosestIndex(leftEpoch);

    final int index = closest <= leftEpoch
        ? closest
        : closest - 1 < 0 ? closest : closest - 1;
    return index - 1 < 0 ? index : index - 1;
  }

  int _searchUpperIndex(int rightEpoch) {
    if (rightEpoch < entries[0].rightEpoch) {
      return -1;
    } else if (rightEpoch > entries[entries.length - 1].rightEpoch) {
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

      if (epoch < entries[mid].rightEpoch) {
        hi = mid - 1;
      } else if (epoch > entries[mid].rightEpoch) {
        lo = mid + 1;
      } else {
        return mid;
      }
    }

    return (entries[lo].rightEpoch - epoch) < (epoch - entries[hi].rightEpoch)
        ? lo
        : hi;
  }

  /// Will be called by the chart when it was updated.
  @override
  void didUpdate(ChartData oldData) {
    final EntrySeries<T> oldSeries = oldData;
    if (oldSeries.entries.isNotEmpty) {
      _prevLastEntry = oldSeries.entries.last;
    }
  }
}
