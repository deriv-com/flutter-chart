import 'package:deriv_chart/deriv_chart.dart';
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
    required this.barrierSpotDistance,
    required this.barrierEpoch,
    this.activeContract,
    this.dragController,
    String? id,
    HorizontalBarrierStyle? style =
        const HorizontalBarrierStyle(labelShape: LabelShape.pentagon),
    this.labelVisibility = HorizontalBarrierVisibility.normal,
  }) : super(
          id ?? 'AccumulatorTickIndicator',
          style: style,
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

  /// [Optional] Active contract information.
  final AccumulatorsActiveContract? activeContract;

  /// The [epoch] of the tick that the barriers belong to.
  final int barrierEpoch;

  /// Tick quote label visibility behavior.
  final HorizontalBarrierVisibility labelVisibility;

  /// [Optional] Makes the barriers draggable.
  ///
  /// Supply a controller (kept alive across rebuilds by the consumer) to let
  /// the user drag either barrier through a ladder of growth rates. When it is
  /// `null` — or disabled — the barriers render exactly as before.
  final AccumulatorBarrierDragController? dragController;

  /// The step the barriers are currently previewing, if a drag is in progress
  /// or a commit is still pending.
  AccumulatorGrowthRateStep? get previewStep =>
      (dragController?.enabled ?? false) && activeContract == null
          ? dragController?.previewStep
          : null;

  @override
  SeriesPainter<Series> createPainter() => AccumulatorIndicatorPainter(this);

  @override
  AccumulatorObject createObject() => AccumulatorObject(
        tick: tick,
        barrierEpoch: barrierEpoch,
        lowBarrier: lowBarrier,
        highBarrier: highBarrier,
        profit: activeContract?.profit,
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
    double bottom = annotationObject.bottomValue!;
    double top = annotationObject.topValue!;

    // While a drag preview is active the painter draws the previewed band, so
    // the Y bounds have to follow it — otherwise a wider preview paints
    // outside the visible quote range.
    final AccumulatorGrowthRateStep? preview = previewStep;
    if (preview != null) {
      final double center =
          (annotationObject.highBarrier + annotationObject.lowBarrier) / 2;
      bottom = center - preview.barrierSpotDistance;
      top = center + preview.barrierSpotDistance;
    }

    final double halfOfBarriersDelta = (top - bottom) / 2;

    return <double>[
      bottom - halfOfBarriersDelta,
      top + halfOfBarriersDelta,
    ];
  }
}
