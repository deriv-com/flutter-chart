import 'package:deriv_chart/src/logic/annotations/barriers/barrier.dart';
import 'package:deriv_chart/src/logic/annotations/barriers/vertical_barrier/vetical_barrier_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/barrier_objects.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';

/// Vertical barrier class
class VerticalBarrier extends Barrier {
  /// Initializes
  VerticalBarrier(
    this.epoch, {
    String id,
    String title,
    BarrierStyle style,
  }) : super(id: id, title: title, style: style);

  /// Epoch of the vertical barrier
  final int epoch;

  @override
  BarrierObject createObject() => VerticalBarrierObject(epoch);

  @override
  SeriesPainter<Series> createPainter() => VerticalBarrierPainter(this);
}
