import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/annotations/barriers/barrier.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/barrier_objects.dart';

import 'horizontal_barrier_painter.dart';

/// Horizontal barrier class
class HorizontalBarrier extends Barrier {
  /// Initializes
  HorizontalBarrier(
    double value, {
    int epoch,
    String id,
    String title,
    bool longLine = true,
    HorizontalBarrierStyle style,
    this.visibility = HorizontalBarrierVisibility.alwaysVisible,
  }) : super(
          id: id,
          title: title,
          epoch: epoch,
          value: value,
          style: style ?? const HorizontalBarrierStyle(),
          longLine: longLine,
        );

  /// Barrier visibility behavior
  final HorizontalBarrierVisibility visibility;

  @override
  SeriesPainter<Series> createPainter() => HorizontalBarrierPainter(this);

  @override
  List<double> recalculateMinMax() =>
  // When its visibility is NOT forceToStayOnRange, we return [NaN, NaN]
  // so it will be excluded from those ChartData that define Y-Axis range.
      visibility == HorizontalBarrierVisibility.forceToStayOnRange
          ? super.recalculateMinMax()
          : <double>[double.nan, double.nan];

  @override
  BarrierObject createObject() => BarrierObject(epoch, null, value);
}

/// Horizontal barrier visibility behavior and whether it contributes in defining
/// the overall Y-Axis range of the chart.
enum HorizontalBarrierVisibility {
  /// Won't force the chart to keep the barrier in its Y-Axis range, if it was
  /// out of range it will go off the screen.
  normal,

  /// Won't force the chart to keep the barrier in its Y-Axis range, if it was
  /// out of range, will show it on top/bottom edge with an arrow which indicates
  /// its value is beyond Y-Axis range.
  alwaysVisible,

  /// Will forces the chart to keep this barrier in its Y-Axis range.
  forceToStayOnRange,
}
