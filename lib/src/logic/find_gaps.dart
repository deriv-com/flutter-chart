import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/models/time_range.dart';

/// Finds time gaps in a list of entries.
///
/// [maxDiff] is the maximum distance between two consecutive entries.
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
