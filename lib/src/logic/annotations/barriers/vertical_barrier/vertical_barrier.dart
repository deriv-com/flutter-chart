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
    this.epoch, {
    this.value,
    String id,
    String title,
    BarrierStyle style,
  }) : super(id: id, title: title, style: style);

  /// A vertical barrier on [Tick]'s epoch
  factory VerticalBarrier.onTick(
    Tick tick, {
    String id,
    String title,
    BarrierStyle style,
  }) =>
      VerticalBarrier(tick.epoch,
          value: tick.quote, id: id, title: title, style: style);

  /// Epoch of the vertical barrier
  final int epoch;

  /// The value that this barrier points to
  final double value;

  @override
  BarrierObject createObject() => BarrierObject(epoch, value);

  @override
  SeriesPainter<Series> createPainter() => VerticalBarrierPainter(this);
}
