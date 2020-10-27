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
  bool isOnRange(int leftBoundEpoch, int rightBoundEpoch) =>
      leftEpoch == null ||
      rightEpoch == null ||
      (leftEpoch > leftBoundEpoch && leftEpoch < rightBoundEpoch) ||
      (rightEpoch > leftBoundEpoch && rightEpoch < rightBoundEpoch);
}
