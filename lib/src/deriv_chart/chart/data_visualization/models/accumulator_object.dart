import 'package:deriv_chart/deriv_chart.dart';

/// A [ChartObject] for defining position of a horizontal barrier.
class AccumulatorObject extends ChartObject {
  /// Initializes a [ChartObject] for defining position of a horizontal barrier.
  const AccumulatorObject({
    required this.tick,
    required this.barrierEpoch,
    required this.lowBarrier,
    required this.highBarrier,
    required this.profit,
    this.barrierEndEpoch,
  }) : super(
          barrierEpoch,
          barrierEndEpoch ?? barrierEpoch,
          lowBarrier,
          highBarrier,
        );

  /// The which this tick indicator will be pointing to.
  final Tick tick;

  /// The low barrier value.
  final double lowBarrier;

  /// The high barrier value.
  final double highBarrier;

  /// The [epoch] of the tick that the barriers belong to.
  final int barrierEpoch;

  /// Barrier End Epoch
  final int? barrierEndEpoch;

  /// [Optional] The profit value which is being shown in the
  /// middle of the tick indicator.
  final double? profit;

  @override
  bool operator ==(covariant AccumulatorObject other) =>
      tick == other.tick &&
      barrierEpoch == other.barrierEpoch &&
      lowBarrier == other.lowBarrier &&
      highBarrier == other.highBarrier &&
      profit == other.profit;

  @override
  int get hashCode =>
      Object.hash(tick, barrierEpoch, lowBarrier, highBarrier, profit);
}
