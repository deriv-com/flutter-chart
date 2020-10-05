import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/annotations/barriers/barrier.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/chart_object.dart';

import 'horizontal_barrier_painter.dart';

/// A [ChartObject] for defining position of a horizontal barrier
class HorizontalBarrierObject extends BarrierObject {
  HorizontalBarrierObject(this.value) : super(null, null, value, value);

  /// Barrier's value
  final double value;
}

/// Horizontal barrier class
class HorizontalBarrier extends Barrier {
  HorizontalBarrier(
    this.value, {
    String id,
    String title,
    BarrierStyle style,
  }) : super(id: id, title: title, style: style);

  /// Value of the barrier
  final double value;

  @override
  SeriesPainter<Series> createPainter() => HorizontalBarrierPainter(this);

  @override
  BarrierObject createObject() => HorizontalBarrierObject(value);
}
