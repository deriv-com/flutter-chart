/// Any component other than chart data (line or candle) which can take a rectangle on the chart's canvas.
abstract class ChartObject {
  /// Initializes
  ChartObject(
    this.leftEpoch,
    this.rightEpoch,
    this.bottomValue,
    this.topValue,
  );

  /// leftEpoch
  final int leftEpoch;

  /// rightEpoch
  final int rightEpoch;

  /// bottomValue
  final double bottomValue;

  /// topValue
  final double topValue;

  /// Whether this chart object is in chart horizontal visible area.
  bool isOnEpochRange(int leftBoundEpoch, int rightBoundEpoch) =>
      leftEpoch == null ||
      rightEpoch == null ||
      _isLeftEpochOnRange(leftBoundEpoch, rightBoundEpoch) ||
      _isRightEpochOnRange(leftBoundEpoch, rightBoundEpoch);

  bool _isRightEpochOnRange(int leftBoundEpoch, int rightBoundEpoch) =>
      rightEpoch > leftBoundEpoch && rightEpoch < rightBoundEpoch;

  bool _isLeftEpochOnRange(int leftBoundEpoch, int rightBoundEpoch) =>
      leftEpoch > leftBoundEpoch && leftEpoch < rightBoundEpoch;

  /// Whether this chart object is in chart horizontal visible area.
  bool isOnValueRange(double bottomBoundValue, double topBoundValue) =>
      bottomValue == null ||
      topValue == null ||
      (bottomValue > bottomBoundValue && bottomValue < topBoundValue) ||
      (topValue > bottomBoundValue && topValue < topBoundValue);
}
