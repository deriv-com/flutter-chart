import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/annotations/barriers/barrier.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';

import 'horizontal_barrier_painter.dart';

class HorizontalBarrierObject extends BarrierObject {
  HorizontalBarrierObject(this.value) : super(null, null, value, value);

  final double value;
}

class HorizontalBarrier extends Barrier {
  HorizontalBarrier(
    this.value, {
    String id,
    String title,
    BarrierStyle style,
  }) : super(id: id, title: title, style: style);

  final double value;

  @override
  SeriesPainter<Series> createPainter() => HorizontalBarrierPainter(this);

  @override
  BarrierObject createObject() => HorizontalBarrierObject(value);
}
