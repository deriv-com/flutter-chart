import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/barrier_objects.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';

import '../barrier.dart';
import 'vertical_barrier_painter.dart';

/// Vertical barrier class.
class VerticalBarrier extends Barrier {
  /// Initializes a vertical barrier class.
  VerticalBarrier(
    int epoch, {
    double? quote,
    String? id,
    String? title,
    BarrierStyle? style,
    bool longLine = true,
  }) : super(
          id: id,
          title: title,
          epoch: epoch,
          quote: quote,
          style: style,
          longLine: longLine,
        );

  /// A vertical barrier on [Tick]'s epoch.
  factory VerticalBarrier.onTick(
    Tick tick, {
    String? id,
    String? title,
    BarrierStyle? style,
    bool longLine = true,
  }) =>
      VerticalBarrier(
        tick.epoch,
        quote: tick.quote,
        id: id,
        title: title,
        style: style,
        longLine: longLine,
      );

  @override
  SeriesPainter<Series> createPainter() => VerticalBarrierPainter(this);

  @override
  BarrierObject createObject() => VerticalBarrierObject(epoch!, quote: quote);

  @override
  bool shouldRepaint(covariant Barrier previous) {
    return true;
  }

  @override
  List<double> recalculateMinMax() =>
      isOnRange ? super.recalculateMinMax() : <double>[double.nan, double.nan];
}
