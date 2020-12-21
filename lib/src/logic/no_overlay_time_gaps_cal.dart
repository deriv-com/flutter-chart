import 'package:deriv_chart/src/models/time_range.dart';
import 'conversion.dart';

/// Calculate time labels' from [gridTimestamps] without any overlaps.
List<DateTime> calculateNoOverlapGridTimestamps(
    List<DateTime> gridTimestamps, List<TimeRange> timeGaps) {
  List<DateTime> _noOverlapGridTimestamps = [];
  if (gridTimestamps == null || gridTimestamps.isEmpty)
    return _noOverlapGridTimestamps;
  for (final DateTime timestamp in gridTimestamps) {
    if (!isInGap(timestamp.millisecondsSinceEpoch, timeGaps)) {
      _noOverlapGridTimestamps.add(timestamp);
    }
  }
  return _noOverlapGridTimestamps;
}

/// returns true if the [epoch] is in [timeGaps]
bool isInGap(int epoch, List<TimeRange> timeGaps) => timeGaps.isEmpty
    ? false
    : timeGaps[indexOfNearestGap(timeGaps, epoch)].contains(epoch);
