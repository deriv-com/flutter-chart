import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/barrier_objects.dart';

import 'accumulators_entry_spot_barrier_painter.dart';


/// Horizontal barrier with entry spot class.
class AccumulatorsEntrySpotBarrier extends Barrier {
  /// Initializes barrier.
  AccumulatorsEntrySpotBarrier(
    double value, {
    this.previousEpoch,
      int? epoch,
    String? id,
    String? title,
    bool longLine = true,
    HorizontalBarrierStyle? style,
    this.visibility =
        AccumulatorsEntrySpotBarrierVisibility.keepBarrierLabelVisible,

  }) : super(
          id: id,
          title: title,
          epoch: epoch,
          value: value,
          style: style,
          longLine: longLine,
        );

  /// Barrier visibility behavior.
  final AccumulatorsEntrySpotBarrierVisibility visibility;

  /// Barrier visibility behavior.
  final int? previousEpoch;

  @override
  SeriesPainter<Series> createPainter() =>
      AccumulatorsEntrySpotBarrierPainter<AccumulatorsEntrySpotBarrier>(this);

  @override
  List<double> recalculateMinMax() =>
      // When its visibility is NOT forceToStayOnRange, we return [NaN, NaN],
      // so the chart will ignore this barrier when it wants to define
      // its Y-Axis range.
      visibility == AccumulatorsEntrySpotBarrierVisibility.forceToStayOnRange
          ? super.recalculateMinMax()
          : <double>[double.nan, double.nan];

  @override
  BarrierObject createObject() => BarrierObject(leftEpoch: epoch, value: value);
}

/// Horizontal barrier visibility behavior and whether it contributes in
/// defining the overall Y-Axis range of the chart.
enum AccumulatorsEntrySpotBarrierVisibility {
  /// Won't force the chart to keep the barrier in its Y-Axis range, if it was
  /// out of range it will go off the screen.
  normal,

  /// Won't force the chart to keep the barrier in its Y-Axis range, if it was
  /// out of range, will show it on top/bottom edge with an arrow which indicates
  /// its value is beyond Y-Axis range.
  keepBarrierLabelVisible,

  /// Will forces the chart to keep this barrier in its Y-Axis range.
  forceToStayOnRange,
}
