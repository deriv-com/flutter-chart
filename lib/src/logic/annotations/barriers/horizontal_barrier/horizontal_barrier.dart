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
    this.keepOnYAxisRange = false,
  }) : super(
          id: id,
          title: title,
          epoch: epoch,
          value: value,
          style: style ?? const HorizontalBarrierStyle(),
          longLine: longLine,
        );

  /// Whether force the chart to keep this barrier on Y-Axis by widening its range.
  ///
  /// In case of `false` when the barrier was out of vertical view port, it will
  /// show it on top/bottom edge with an arrow which indicates its value it out of range.
  final bool keepOnYAxisRange;

  @override
  SeriesPainter<Series> createPainter() => HorizontalBarrierPainter(this);

  @override
  List<double> recalculateMinMax() => keepOnYAxisRange
      ? super.recalculateMinMax()
      : <double>[double.nan, double.nan];

  @override
  BarrierObject createObject() => BarrierObject(epoch, null, value);
}
