import 'chart_object.dart';

/// A [ChartObject] for defining position of a horizontal barrier.
class BarrierObject extends ChartObject {
  /// Initializes a [ChartObject] for defining position of a horizontal barrier.
  const BarrierObject({
    int? leftEpoch,
    int? rightEpoch,
    this.quote,
  }) : super(leftEpoch, rightEpoch, quote, quote);

  /// Barrier's value.
  final double? quote;
}

/// Vertical barrier object.
class VerticalBarrierObject extends BarrierObject {
  /// Initializes a vertical barrier object.
  const VerticalBarrierObject(
    this.epoch, {
    double? quote,
  }) : super(leftEpoch: epoch, rightEpoch: epoch, quote: quote);

  /// Epoch of the vertical barrier.
  final int epoch;
}
