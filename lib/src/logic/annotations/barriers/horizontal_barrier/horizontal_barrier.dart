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
  }) : super(
          id: id,
          title: title,
          epoch: epoch,
          value: value,
          style: style ?? const HorizontalBarrierStyle(),
          longLine: longLine,
        );

  @override
  SeriesPainter<Series> createPainter() => HorizontalBarrierPainter(this);

  @override
  List<double> recalculateMinMax() => epoch == null
      ? super.recalculateMinMax()
      : <double>[double.nan, double.nan];

  @override
  BarrierObject createObject() => BarrierObject(epoch, null, value);
}
