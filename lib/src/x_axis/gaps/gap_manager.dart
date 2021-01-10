import 'package:deriv_chart/src/models/time_range.dart';
import 'package:deriv_chart/src/x_axis/gaps/helpers.dart';

/// Manages time gaps (closed market time) on x-axis.
class GapManager {
  /// The list of time gaps that the market is closed in the given time.
  List<TimeRange> gaps = [];

  /// Cumulative sums of gap durations from right to left.
  /// Allows getting a sum of any gap range in constant time.
  ///
  /// Right to left is chosen to avoid recalculations,
  /// since new gaps are added on the left.
  ///
  /// Example:
  /// 10-20 30-40 60-80 - [gaps]
  /// 10    10    20    - gap durations
  /// 40    30    20    - [_cumulativeSums]
  List<int> _cumulativeSums = [];

  /// Replaces the [gaps] with the given [newGaps],
  void replaceGaps(List<TimeRange> newGaps) {
    gaps = newGaps;
    _cumulativeSums = _calcCumulativeSums(newGaps);
  }

  /// Inserts [newGaps] in start of the [gaps].
  void insertInFront(List<TimeRange> newGaps) {
    gaps = newGaps + gaps;

    final List<int> newSums = _calcCumulativeSums(
      newGaps,
      startSum: _cumulativeSums.isNotEmpty ? _cumulativeSums.first : 0,
    );
    _cumulativeSums = newSums + _cumulativeSums;
  }

  List<int> _calcCumulativeSums(List<TimeRange> gaps, {int startSum = 0}) {
    List<int> sums = [];
    int sum = startSum;

    for (final TimeRange gap in gaps.reversed) {
      sum += gap.duration;
      sums.insert(0, sum);
    }
    return sums;
  }

  /// Duration of [range] on x-axis without gaps.
  int removeGaps(TimeRange range) {
    if (gaps.isEmpty) {
      return range.duration;
    }

    final int left = indexOfNearestGap(gaps, range.leftEpoch);
    final int right = indexOfNearestGap(gaps, range.rightEpoch);

    int overlap = 0;

    overlap += gaps[left].overlap(range)?.duration ?? 0;
    if (left != right) {
      overlap += gaps[right].overlap(range)?.duration ?? 0;
    }

    if (left + 1 < right) {
      overlap += _cumulativeSums[left + 1] - _cumulativeSums[right];
    }
    return range.duration - overlap;
  }

  /// Whether given [epoch] falls into a time gap.
  bool isInGap(int epoch) =>
      gaps.isNotEmpty && gaps[indexOfNearestGap(gaps, epoch)].contains(epoch);
}
