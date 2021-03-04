import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

/// Line series.
class LineSeries extends DataSeries<Tick> {
  /// Initializes a line series.
  LineSeries(
    List<Tick> entries, {
    List<double> horizontalLines = const <double>[],
    String id,
    LineStyle style,
    LineStyle horizontalLinesStyle,
  })  : _horizontalLines = horizontalLines,
        _horizontalLinesStyle = horizontalLinesStyle,
        super(entries, id, style: style);

  final List<double> _horizontalLines;
  final LineStyle _horizontalLinesStyle;

  @override
  SeriesPainter<DataSeries<Tick>> createPainter() => LinePainter(this,
      horizontalLines: _horizontalLines,
      horizontalLineStyle: _horizontalLinesStyle);

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
