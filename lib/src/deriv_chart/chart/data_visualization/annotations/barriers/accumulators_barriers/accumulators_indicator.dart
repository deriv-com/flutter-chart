import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/accumulator_object.dart';

import 'accumulators_indicator_painter.dart';

/// Accumulator Barriers.
class AccumulatorIndicator extends ChartAnnotation<AccumulatorObject> {
  /// Initializes a tick indicator.
  AccumulatorIndicator(
    this.tick, {
    required this.lowBarrier,
    required this.highBarrier,
    required this.highBarrierDisplay,
    required this.lowBarrierDisplay,
    required this.profit,
    required this.barrierSpotDistance,
    required this.barrierEpoch,
    required this.isActiveContract,
    String? id,
  }) : super(
          id ?? 'AccumulatorTickIndicator',
        );

  /// The price difference between the barrier and the [tick] quote.
  final String barrierSpotDistance;

  /// The which this tick indicator will be pointing to.
  final Tick tick;

  /// The low barrier value.
  final double lowBarrier;

  /// The high barrier value.
  final double highBarrier;

  /// The low barrier display value.
  final String highBarrierDisplay;

  /// The high barrier display value.
  final String lowBarrierDisplay;

  /// [Optional] The profit value which is being shown in the middle of the tick indicator.
  final String? profit;

  /// The [epoch] of the tick that the barriers belong to.
  final int barrierEpoch;

  /// Weathers there is an active contract or not.
  final bool isActiveContract;

  @override
  SeriesPainter<Series> createPainter() => AccumulatorIndicatorPainter(this);

  @override
  AccumulatorObject createObject() => AccumulatorObject(
        tick: tick,
        barrierEpoch: barrierEpoch,
        lowBarrier: lowBarrier,
        highBarrier: highBarrier,
      );

  @override
  int? getMaxEpoch() => barrierEpoch;

  @override
  int? getMinEpoch() => barrierEpoch;
}
