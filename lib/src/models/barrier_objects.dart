// @dart=2.9

import 'package:deriv_chart/src/models/chart_object.dart';

/// A [ChartObject] for defining position of a horizontal barrier.
class BarrierObject extends ChartObject {
  /// Initializes a [ChartObject] for defining position of a horizontal barrier.
  const BarrierObject({
    int leftEpoch,
    int rightEpoch,
    this.value,
  }) : super(leftEpoch, rightEpoch, value, value);

  /// Barrier's value.
  final double value;
}

/// Vertical barrier object.
class VerticalBarrierObject extends BarrierObject {
  /// Initializes a vertical barrier object.
  const VerticalBarrierObject(
    this.epoch, {
    double value,
  }) : super(leftEpoch: epoch, rightEpoch: epoch, value: value);

  /// Epoch of the vertical barrier.
  final int epoch;
}
