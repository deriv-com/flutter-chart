import 'dart:math';

class TimeRange {
  TimeRange(this.leftEpoch, this.rightEpoch) : assert(leftEpoch <= rightEpoch);

  final int leftEpoch;
  final int rightEpoch;

  int get msWidth => rightEpoch - leftEpoch;

  int overlap(TimeRange other) {
    final int left = max(other.leftEpoch, leftEpoch);
    final int right = min(other.rightEpoch, rightEpoch);
    return right <= left ? 0 : right - left;
  }
}
