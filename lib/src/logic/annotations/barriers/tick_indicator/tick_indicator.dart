import 'package:deriv_chart/src/logic/annotations/chart_annotation.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/barrier_objects.dart';
import 'package:deriv_chart/src/models/chart_object.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/current_tick_style.dart';

import 'tick_indicator_painter.dart';

/// Last tick indicator barrier
class TickIndicator extends ChartAnnotation<BarrierObject> {
  /// Initializes the [tick]
  TickIndicator(this.tick, {String id, CurrentTickStyle currentTickStyle})
      : super(id, style: currentTickStyle ?? const CurrentTickStyle());

  /// The tick that this indicator should show its value.
  final Tick tick;

  @override
  BarrierObject createObject() => BarrierObject(tick.epoch, tick.quote);

  @override
  SeriesPainter<Series> createPainter() => TickIndicatorPainter(this);

  // We return NaN cause we don't want to contribute last tick indicator in the
  // process of defining min/max of the chart's y-axis.
  @override
  List<double> recalculateMinMax() => <double>[double.nan, double.nan];
}
