import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';

/// Line series.
class LineSeries extends DataSeries<Tick> {
  /// Initializes a line series.
  LineSeries(
    List<Tick> entries, {
    String? id,
    LineStyle? style,
    HorizontalBarrierStyle? lastTickIndicatorStyle,
  }) : super(
          entries,
          id: id ?? 'LineSeries',
          style: style,
          lastTickIndicatorStyle: lastTickIndicatorStyle,
        );

  @override
  SeriesPainter<DataSeries<Tick>> createPainter() => LinePainter(
        this,
      );

  @override
  Widget getCrossHairInfo(Tick crossHairTick, int pipSize, ChartTheme theme) =>
      Text(
        '${crossHairTick.quote.toStringAsFixed(pipSize)}',
        style: const TextStyle(fontSize: 16),
      );

  @override
  double maxValueOf(Tick t) => t.quote;

  @override
  double minValueOf(Tick t) => t.quote;
}
