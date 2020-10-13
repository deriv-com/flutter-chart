import 'package:deriv_chart/src/models/chart_object.dart';

/// Barrier object
abstract class BarrierObject extends ChartObject {
  /// Initializes
  BarrierObject(
    int leftEpoch,
    int rightEpoch,
    double bottomValue,
    double topValue,
  ) : super(leftEpoch, rightEpoch, bottomValue, topValue);
}

/// A [ChartObject] for defining position of a vertical barrier
class VerticalBarrierObject extends BarrierObject {
  /// Initializes
  VerticalBarrierObject(this.epoch)
      : super(epoch, epoch, double.nan, double.nan);

  /// Epoch of the vertical barrier.
  final int epoch;
}

/// A [ChartObject] for defining position of a horizontal barrier
class HorizontalBarrierObject extends BarrierObject {
  /// Initializes
  HorizontalBarrierObject(
    this.value,
    this.start,
  ) : super(start, start, value, value);

  /// Barrier's value
  final double value;

  /// Barrier's start epoch
  final int start;
}
