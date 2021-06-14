import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/models/time_range.dart';

/// Finds time gaps in a list of entries.
///
/// [maxDiff] is the maximum distance between two consecutive entries in milliseconds.
List<TimeRange> findGaps(List<Tick> entries, int maxDiff) {
  final List<TimeRange> gaps = <TimeRange>[];

  for (int i = 1; i < entries.length; i++) {
    final Tick left = entries[i - 1];
    final Tick right = entries[i];

    if (right.epoch - left.epoch > maxDiff) {
      gaps.add(TimeRange(left.epoch + maxDiff, right.epoch));
    }
  }
  return gaps;
}

/// Returns index of the gap in the given list, that either contains the given [epoch] or is to the left/right to it.
int indexOfNearestGap(List<TimeRange> gaps, int epoch) {
  int left = 0, right = gaps.length - 1;
  while (left < right) {
    final int mid = (left + right) ~/ 2;

    if (gaps[mid].isAfter(epoch)) {
      right = mid;
    } else if (gaps[mid].isBefore(epoch)) {
      left = mid + 1;
    } else {
      return mid;
    }
  }
  return right;
}
