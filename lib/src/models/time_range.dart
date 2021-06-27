import 'dart:math';

/// Representation of a time range on x-axis.
class TimeRange {
  /// Creates a time range between two epochs.
  /// [leftEpoch] must be before or equal [rightEpoch].
  TimeRange(this.leftEpoch, this.rightEpoch) : assert(leftEpoch <= rightEpoch);

  /// Inclusive left epoch bound.
  final int leftEpoch;

  /// Inclusive right epoch bound.
  final int rightEpoch;

  /// Time distance between left and right epochs.
  int get duration => rightEpoch - leftEpoch;

  /// Returns overlap between this and [other] time range.
  /// Returns `null` if there is no overlap.
  TimeRange? overlap(TimeRange other) {
    final int left = max(other.leftEpoch, leftEpoch);
    final int right = min(other.rightEpoch, rightEpoch);
    return right <= left ? null : TimeRange(left, right);
  }

  /// Whether this time range contains the given epoch, including the bounds.
  bool contains(int epoch) => leftEpoch <= epoch && epoch < rightEpoch;

  /// Whether this time range is before the given epoch.
  bool isBefore(int epoch) => rightEpoch < epoch;

  /// Whether this time range is after the given epoch.
  bool isAfter(int epoch) => epoch < leftEpoch;

  @override
  String toString() => 'TimeRange($leftEpoch, $rightEpoch)';
}
