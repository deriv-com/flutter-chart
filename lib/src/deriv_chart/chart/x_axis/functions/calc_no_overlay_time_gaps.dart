/// Calculate time labels' from [gridTimestamps] without any overlaps.
List<DateTime> calculateNoOverlapGridTimestamps(
  List<DateTime> gridTimestamps,
  double minDistanceBetweenTimeGridLines,

  /// Px distance between two epochs minus the time gaps.
  double Function(int leftEpoch, int rightEpoch) pxBetween,

  /// Does the given epoch fall into a time gap.
  bool Function(int) isInGap,
) {
  final List<DateTime> _noOverlapGridTimestamps = <DateTime>[];
  if (gridTimestamps.isEmpty) {
    return _noOverlapGridTimestamps;
  }
  // check if timestamp is not have overlap with Previous timestamp
  bool noOverlapWithPrevious(int timestamp) =>
      _noOverlapGridTimestamps.isEmpty ||
      pxBetween(_noOverlapGridTimestamps.last.millisecondsSinceEpoch,
              timestamp) >=
          minDistanceBetweenTimeGridLines;

  for (final DateTime timestamp in gridTimestamps) {
    // check if timestamp is not in gap
    if (!isInGap(timestamp.millisecondsSinceEpoch) &&
        noOverlapWithPrevious(timestamp.millisecondsSinceEpoch)) {
      _noOverlapGridTimestamps.add(timestamp);
    }
  }
  return _noOverlapGridTimestamps;
}
