import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/extensions/extensions.dart';
import 'package:flutter/material.dart';

/// Any component other than chart data (line or candle) which can take a
/// rectangle on the chart's canvas.
@immutable
abstract class ChartObject {
  /// Initializes
  const ChartObject(
    this.leftEpoch,
    this.rightEpoch,
    this.bottomValue,
    this.topValue,
  );

  /// leftEpoch
  final int? leftEpoch;

  /// rightEpoch
  final int? rightEpoch;

  /// bottomValue
  final double? bottomValue;

  /// topValue
  final double? topValue;

  @override
  bool operator ==(covariant ChartObject other) =>
      leftEpoch == other.leftEpoch &&
      rightEpoch == other.rightEpoch &&
      topValue == other.topValue &&
      bottomValue == other.bottomValue;

  @override
  int get hashCode => Object.hash(leftEpoch, rightEpoch, topValue, bottomValue);

  /// Whether this chart object is in chart horizontal visible area.
  bool isOnEpochRange(int leftBoundEpoch, int rightBoundEpoch) =>
      leftEpoch == null ||
      rightEpoch == null ||
      _coversEpochRange(leftBoundEpoch, rightBoundEpoch) ||
      _isLeftEpochOnRange(leftBoundEpoch, rightBoundEpoch) ||
      _isRightEpochOnRange(leftBoundEpoch, rightBoundEpoch);

  bool _isRightEpochOnRange(int leftBoundEpoch, int rightBoundEpoch) {
    final double safeDistance =
        edgePointOffScreenSafeDistance(leftBoundEpoch, rightBoundEpoch);

    return rightEpoch! > leftBoundEpoch - safeDistance &&
        rightEpoch! < rightBoundEpoch + safeDistance;
  }

  bool _isLeftEpochOnRange(int leftBoundEpoch, int rightBoundEpoch) {
    final double safeDistance =
        edgePointOffScreenSafeDistance(leftBoundEpoch, rightBoundEpoch);
    return leftEpoch! > leftBoundEpoch - safeDistance &&
        leftEpoch! < rightBoundEpoch + safeDistance;
  }

  bool _coversEpochRange(int leftBoundEpoch, int rightBoundEpoch) =>
      leftEpoch! <= leftBoundEpoch && rightEpoch! >= rightBoundEpoch;

  /// Whether this chart object is in chart horizontal visible area.
  bool isOnValueRange(double bottomBoundValue, double topBoundValue) =>
      bottomValue == null ||
      topValue == null ||
      _coversValueRange(bottomBoundValue, topBoundValue) ||
      _isBottomValueOnRange(bottomBoundValue, topBoundValue) ||
      _isTopValueOnRange(bottomBoundValue, topBoundValue);

  bool _coversValueRange(double bottomBoundValue, double topBoundValue) =>
      bottomValue! <= bottomBoundValue && topValue! > topBoundValue;

  bool _isTopValueOnRange(double bottomBoundValue, double topBoundValue) =>
      topValue! > bottomBoundValue && topValue! < topBoundValue;

  bool _isBottomValueOnRange(double bottomBoundValue, double topBoundValue) =>
      bottomValue! > bottomBoundValue && bottomValue! < topBoundValue;
}
