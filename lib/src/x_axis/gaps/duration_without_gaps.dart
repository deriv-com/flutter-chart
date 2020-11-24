import 'package:deriv_chart/src/models/time_range.dart';

int _indexOfGapThatContainsOrNearEpoch(List<TimeRange> gaps, int epoch) {
  int low = 0, high = gaps.length - 1;

  while (low < high) {
    final int mid = (low + high) >> 1;
    if (gaps[mid].isBefore(epoch)) {
      high = mid;
    } else if (gaps[mid].isAfter(epoch)) {
      low = mid + 1;
    } else {
      return mid;
    }
  }
  return low;
}

/// [range] duration with [gaps] removed.
int durationWithoutGaps(
  TimeRange range,
  List<TimeRange> gaps,
) {
  final int left = _indexOfGapThatContainsOrNearEpoch(gaps, range.leftEpoch);
  final int right = _indexOfGapThatContainsOrNearEpoch(gaps, range.rightEpoch);

  int overlap = 0;

  overlap += gaps[left].overlap(range)?.duration ?? 0;
  overlap += gaps[right].overlap(range)?.duration ?? 0;

  for (int i = left + 1; i < right; i++) {
    overlap += gaps[i].duration;
  }
  return range.duration - overlap;
}
