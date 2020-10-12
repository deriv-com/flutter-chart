import 'package:deriv_chart/src/logic/annotations/chart_annotation.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/chart_object.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/current_tick_style.dart';

import 'last_tick_indicator_painter.dart';

/// Last tick indicator object.
class LastTickObject extends ChartObject {
  /// Initializes the [tick]
  LastTickObject(this.tick)
      : super(tick.epoch, tick.epoch, tick.quote, tick.quote);

  /// The tick of the
  final Tick tick;
}

/// Last tick indicator barrier
class LastTickIndicator extends ChartAnnotation<LastTickObject> {
  /// Initializes the [tick]
  LastTickIndicator(this.tick, {String id, CurrentTickStyle currentTickStyle})
      : super(id, style: currentTickStyle ?? const CurrentTickStyle());

  /// The tick that this indicator should show its value.
  final Tick tick;

  @override
  LastTickObject createObject() => LastTickObject(tick);

  @override
  SeriesPainter<Series> createPainter() => LastTickIndicatorPainter(this);

  // We return NaN cause we don't want to contribute last tick indicator in the
  // process of defining min/max values of the chart's y-axis.
  @override
  List<double> recalculateMinMax() => <double>[double.nan, double.nan];
}
