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
    this.value, {
    this.startEpoch,
    String id,
    String title,
    BarrierStyle style,
  }) : super(
          id: id,
          title: title,
          style: style ?? const HorizontalBarrierStyle(),
        );

  /// Value of the barrier
  final double value;

  /// Start epoch
  final int startEpoch;

  @override
  SeriesPainter<Series> createPainter() => HorizontalBarrierPainter(this);

  @override
  BarrierObject createObject() => BarrierObject(startEpoch, value);
}
