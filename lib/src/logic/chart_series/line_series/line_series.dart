import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_renderable.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

/// Line series
class LineSeries extends DataSeries<Tick> {
  /// Initializes
  LineSeries(
    List<Tick> entries, {
    String id,
    LineStyle style,
  }) : super(entries, id, style: style ?? const LineStyle());

  @override
  void createRenderable() => rendererable = LineRenderable(this);

  @override
  Widget getCrossHairInfo(Tick crossHairTick, int pipSize) => Text(
        '${crossHairTick.quote.toStringAsFixed(pipSize)}',
        style: const TextStyle(fontSize: 16),
      );

  @override
  double maxValueOf(Tick t) => t.quote;

  @override
  double minValueOf(Tick t) => t.quote;
}
