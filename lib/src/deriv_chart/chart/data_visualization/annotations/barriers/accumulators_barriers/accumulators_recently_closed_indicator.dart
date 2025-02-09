import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/accumulator_object.dart';

import 'accumulators_recently_closed_indicator_painter.dart';

/// Accumulator Closed Contract Barriers.
class AccumulatorsRecentlyClosedIndicator
    extends ChartAnnotation<AccumulatorObject> {
  /// Initializes a tick indicator.
  AccumulatorsRecentlyClosedIndicator(
    this.exitTick, {
    required this.lowBarrier,
    required this.highBarrier,
    required this.highBarrierDisplay,
    required this.lowBarrierDisplay,
    required this.barrierSpotDistance,
    required this.barrierEpoch,
    required this.activeContract,
    required this.barrierEndEpoch,
    super.style,
    String? id,
  }) : super(id ?? 'AccumulatorsClosedIndicator');

  /// The price difference between the barrier and the barrier Tick quote.
  final String barrierSpotDistance;

  /// The which this tick indicator will be pointing to.
  final Tick exitTick;

  /// The low barrier value.
  final double lowBarrier;

  /// The high barrier value.
  final double highBarrier;

  /// The low barrier display value.
  final String highBarrierDisplay;

  /// The high barrier display value.
  final String lowBarrierDisplay;

  /// [Optional] Active contract information.
  final AccumulatorsActiveContract? activeContract;

  /// The [epoch] of the tick that the barriers belong to.
  final int barrierEpoch;

  /// Barrier end epoch.
  final int barrierEndEpoch;

  @override
  SeriesPainter<Series> createPainter() =>
      AccumulatorsRecentlyClosedIndicatorPainter(this);

  @override
  AccumulatorObject createObject() => AccumulatorObject(
        tick: exitTick,
        barrierEpoch: barrierEpoch,
        lowBarrier: lowBarrier,
        highBarrier: highBarrier,
        profit: activeContract?.profit,
        barrierEndEpoch: barrierEndEpoch,
      );

  @override
  int? getMaxEpoch() => barrierEpoch;

  @override
  int? getMinEpoch() => barrierEpoch;

  @override
  List<double> recalculateMinMax() {
    if (annotationObject.bottomValue == null ||
        annotationObject.topValue == null ||
        !isOnRange) {
      return <double>[double.nan, double.nan];
    }
    final double halfOfBarriersDelta =
        (annotationObject.highBarrier - annotationObject.lowBarrier) / 2;

    return <double>[
      annotationObject.bottomValue! - halfOfBarriersDelta,
      annotationObject.topValue! + halfOfBarriersDelta,
    ];
  }
}
