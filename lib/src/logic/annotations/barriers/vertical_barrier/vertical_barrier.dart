import 'package:deriv_chart/src/logic/annotations/barriers/barrier.dart';
import 'package:deriv_chart/src/logic/annotations/barriers/vertical_barrier/vetical_barrier_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/barrier_objects.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';

/// Vertical barrier class
class VerticalBarrier extends Barrier {
  /// Initializes
  VerticalBarrier(
    int epoch, {
    double value,
    String id,
    String title,
    BarrierStyle style,
    bool longLine = true,
  }) : super(
          id: id,
          title: title,
          epoch: epoch,
          value: value,
          style: style,
          longLine: longLine,
        );

  /// A vertical barrier on [Tick]'s epoch
  factory VerticalBarrier.onTick(
    Tick tick, {
    String id,
    String title,
    BarrierStyle style,
    bool longLine,
  }) =>
      VerticalBarrier(
        tick.epoch,
        value: tick.quote,
        id: id,
        title: title,
        style: style,
        longLine: longLine ?? true,
      );

  @override
  SeriesPainter<Series> createPainter() => VerticalBarrierPainter(this);

  @override
  BarrierObject createObject() => VerticalBarrierObject(epoch, value);

  @override
  List<double> recalculateMinMax() =>
      isOnRange ? super.recalculateMinMax() : <double>[double.nan, double.nan];
}
