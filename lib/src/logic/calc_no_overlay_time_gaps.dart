import 'package:deriv_chart/src/models/time_range.dart';
import 'conversion.dart';

/// Calculate time labels' from [gridTimestamps] without any overlaps.
List<DateTime> calculateNoOverlapGridTimestamps(
    List<DateTime> gridTimestamps,
    List<TimeRange> timeGaps,
    double msPerPx,
    double minDistanceBetweenTimeGridLines) {
  final List<DateTime> _noOverlapGridTimestamps = [];
  if (gridTimestamps == null || gridTimestamps.isEmpty) {
    return _noOverlapGridTimestamps;
  }
  // check if timestamp is not have overlap with Previous timestamp
  bool noOverlapWithPrevious(int timestamp) =>
      _noOverlapGridTimestamps.isEmpty ||
      timeRangePxWidth(
              range: TimeRange(
                _noOverlapGridTimestamps.last.millisecondsSinceEpoch,
                timestamp,
              ),
              msPerPx: msPerPx,
              gaps: timeGaps) >=
          minDistanceBetweenTimeGridLines;

  for (final DateTime timestamp in gridTimestamps) {
    // check if timestamp is not in gap
    if (!isInGap(timestamp.millisecondsSinceEpoch, timeGaps) &&
        noOverlapWithPrevious(timestamp.millisecondsSinceEpoch)) {
      _noOverlapGridTimestamps.add(timestamp);
    }
  }
  return _noOverlapGridTimestamps;
}

/// returns true if the [epoch] is in [timeGaps]
bool isInGap(int epoch, List<TimeRange> timeGaps) => timeGaps.isEmpty
    ? false
    : timeGaps[indexOfNearestGap(timeGaps, epoch)].contains(epoch);
