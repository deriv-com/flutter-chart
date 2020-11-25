import 'package:deriv_chart/src/models/time_range.dart';
import 'package:deriv_chart/src/x_axis/gaps/duration_without_gaps.dart';

/// Manages time gaps (closed market time) on x-axis.
class GapManager {
  List<TimeRange> gaps = [];

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
