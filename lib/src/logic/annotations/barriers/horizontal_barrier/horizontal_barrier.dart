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
    this.epoch,
    String id,
    String title,
    bool longLine = true,
    HorizontalBarrierStyle style,
  }) : super(
          id: id,
          title: title,
          style: style ?? const HorizontalBarrierStyle(),
          longLine: longLine,
        );

  /// Value of the barrier
  final double value;

  /// Start epoch
  final int epoch;

  @override
  SeriesPainter<Series> createPainter() => HorizontalBarrierPainter(this);

  @override
  BarrierObject createObject() => BarrierObject(epoch, value);

  @override
  List<double> recalculateMinMax() => epoch == null
      ? super.recalculateMinMax()
      : <double>[double.nan, double.nan];
}

/// Tick indicator
class TickIndicator extends HorizontalBarrier {
  /// Initializes
  TickIndicator(
    Tick tick, {
    String id,
    HorizontalBarrierStyle style,
  }) : super(
          tick.quote,
          epoch: tick.epoch,
          id: id,
          style: style ?? HorizontalBarrierStyle,
          longLine: false,
        );

  @override
  List<double> recalculateMinMax() => <double>[double.nan, double.nan];
}
