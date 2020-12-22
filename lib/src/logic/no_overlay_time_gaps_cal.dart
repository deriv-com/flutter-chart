import 'package:deriv_chart/src/models/time_range.dart';
import 'conversion.dart';

/// Calculate time labels' from [gridTimestamps] without any overlaps.
List<DateTime> calculateNoOverlapGridTimestamps(
    List<DateTime> gridTimestamps, List<TimeRange> timeGaps, double msPerPx) {
  List<DateTime> _noOverlapGridTimestamps = [];
  const int _minDistanceBetweenTimeGridLines = 80;
  if (gridTimestamps == null || gridTimestamps.isEmpty)
    return _noOverlapGridTimestamps;
  for (final DateTime timestamp in gridTimestamps) {
    // check if timestamp is not in gap
    if (!isInGap(timestamp.millisecondsSinceEpoch, timeGaps)) {
      // check if time label have enough distance with previous one
      if (_noOverlapGridTimestamps.isNotEmpty &&
          timeRangePxWidth(
                  range: TimeRange(
                    _noOverlapGridTimestamps.last.millisecondsSinceEpoch,
                    timestamp.millisecondsSinceEpoch,
                  ),
                  msPerPx: msPerPx,
                  gaps: timeGaps) <
              _minDistanceBetweenTimeGridLines) {
        continue;
      }
      _noOverlapGridTimestamps.add(timestamp);
    }
  }
  return _noOverlapGridTimestamps;
}

/// returns true if the [epoch] is in [timeGaps]
bool isInGap(int epoch, List<TimeRange> timeGaps) => timeGaps.isEmpty
    ? false
    : timeGaps[indexOfNearestGap(timeGaps, epoch)].contains(epoch);
