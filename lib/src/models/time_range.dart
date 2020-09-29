import 'dart:math';

class TimeRange {
  TimeRange(this.leftEpoch, this.rightEpoch) : assert(leftEpoch <= rightEpoch);

  final int leftEpoch;
  final int rightEpoch;

  int get msWidth => rightEpoch - leftEpoch;

  TimeRange overlap(TimeRange other) {
    final int left = max(other.leftEpoch, leftEpoch);
    final int right = min(other.rightEpoch, rightEpoch);
    return right <= left ? null : TimeRange(left, right);
  }

  bool contains(int epoch) => leftEpoch <= epoch && epoch <= rightEpoch;

  bool isBefore(int epoch) => rightEpoch < epoch;

  bool isAfter(int epoch) => epoch < leftEpoch;
}
