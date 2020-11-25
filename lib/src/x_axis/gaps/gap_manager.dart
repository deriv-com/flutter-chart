import 'package:deriv_chart/src/models/time_range.dart';
import 'package:deriv_chart/src/x_axis/gaps/duration_without_gaps.dart';

/// Manages time gaps (closed market time) on x-axis.
class GapManager {
  List<TimeRange> gaps = [];

  /// Cumulative sums of gap durations from right to left.
  /// Allows getting a sum of any gap range in constant time.
  ///
  /// Right to left is chosed to avoid recalculations,
  /// since new gaps are added on the left.
  ///
  /// Example:
  /// 10-20 30-40 60-80 - [gaps]
  /// 10    10    20    - gap durations
  /// 40    30    20    - [_cumulativeSums]
  List<int> _cumulativeSums;

  void replaceGaps(List<TimeRange> newGaps) {
    gaps = newGaps;
  }

  void insertInFront(List<TimeRange> newGaps) {
    gaps = newGaps + gaps;
  }

  /// Milliseconds between [leftEpoch] and [rightEpoch] on x-axis without gaps.
  int removeGaps(int leftEpoch, int rightEpoch) => durationWithoutGaps(
        TimeRange(leftEpoch, rightEpoch),
        gaps,
      );
}
