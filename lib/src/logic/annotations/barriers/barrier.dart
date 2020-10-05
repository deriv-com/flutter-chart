import 'package:deriv_chart/src/logic/annotations/barriers/barrier_painter.dart';
import 'package:deriv_chart/src/logic/annotations/chart_annotation.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/chart_object.dart';

class BarrierObject extends ChartObject {
  BarrierObject(this.value) : super(null, null, value, value);

  final double value;
}

class Barrier extends ChartAnnotation<BarrierObject> {
  Barrier(
    this.value, {
    String id,
    String title,
  }) : super(id) {
    annotationObject = BarrierObject(value);
  }

  final double value;

  @override
  SeriesPainter<Series> createPainter() => BarrierPainter(this);
}
