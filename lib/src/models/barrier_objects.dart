import 'package:deriv_chart/src/models/chart_object.dart';

/// A [ChartObject] for defining position of a horizontal barrier
class BarrierObject extends ChartObject {
  /// Initializes
  BarrierObject(
    this.epoch,
    this.value,
  ) : super(epoch, epoch, value, value);

  /// Barrier's value
  final double value;

  /// Barrier's start epoch
  final int epoch;
}
