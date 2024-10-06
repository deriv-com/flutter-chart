import 'package:deriv_chart/deriv_chart.dart';

/// Line barrier object to annotate line start edge point and end edge point
/// on the chart. It will have two quote in the y-axis and two epoch in the
/// x-axis of the respective edge points.
class LineBarrierObject extends ChartObject {
  /// Initializes a line barrier object.
  const LineBarrierObject({
    required this.startBarrier,
    required this.endBarrier,
    required this.barrierStartEpoch,
    required this.barrierEndEpoch,
  }) : super(barrierStartEpoch, barrierEndEpoch, startBarrier, endBarrier);

  /// Start edge point of the line.
  final double startBarrier;

  /// End edge point of the line.
  final double endBarrier;

  /// The [epoch] of the tick that the barriers belong to.
  final int barrierStartEpoch;

  /// Barrier End Epoch
  final int barrierEndEpoch;

  @override
  bool operator ==(covariant LineBarrierObject other) =>
      startBarrier == other.startBarrier &&
      endBarrier == other.endBarrier &&
      barrierStartEpoch == other.barrierStartEpoch &&
      barrierEndEpoch == other.barrierEndEpoch;

  @override
  int get hashCode =>
      Object.hash(startBarrier, endBarrier, barrierStartEpoch, barrierEndEpoch);
}
