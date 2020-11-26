import 'package:deriv_chart/src/models/time_range.dart';

/// Manages time gaps (closed market time) on x-axis.
class GapManager {
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

  void replaceGaps(List<TimeRange> newGaps) {
    gaps = newGaps;
    _cumulativeSums = _calcCumulativeSums(newGaps);
  }

  void insertInFront(List<TimeRange> newGaps) {
    gaps = newGaps + gaps;
    _cumulativeSums = _calcCumulativeSums(
      newGaps,
      startSum: _cumulativeSums.first,
    );
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

    final int left = _indexOfGapThatContainsOrNearEpoch(gaps, range.leftEpoch);
    final int right =
        _indexOfGapThatContainsOrNearEpoch(gaps, range.rightEpoch);

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

  int _indexOfGapThatContainsOrNearEpoch(List<TimeRange> gaps, int epoch) {
    int low = 0, high = gaps.length - 1;

    while (low < high) {
      final int mid = (low + high) >> 1;
      if (gaps[mid].isBefore(epoch)) {
        low = mid + 1;
      } else if (gaps[mid].isAfter(epoch)) {
        high = mid;
      } else {
        return mid;
      }
    }
    return low;
  }
}
