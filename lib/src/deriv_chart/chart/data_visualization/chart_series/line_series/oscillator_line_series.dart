import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data_series.dart';
import '../series_painter.dart';
import 'oscillator_line_painter.dart';

/// Oscillator Line Series.
class OscillatorLineSeries extends LineSeries {
  /// Initializes an Oscillator line series.
  OscillatorLineSeries(
    List<Tick> entries, {
    required double topHorizontalLine,
    required double bottomHorizontalLine,
    List<double> secondaryHorizontalLines = const <double>[],
    LineStyle style = const LineStyle(),
    String? id,
    LineStyle? secondaryHorizontalLinesStyle =
        const LineStyle(color: Colors.white60),
    LineStyle? mainHorizontalLinesStyle =
        const LineStyle(color: Colors.blueGrey),
  })  : _topHorizontalLine = topHorizontalLine,
        _bottomHorizontalLine = bottomHorizontalLine,
        _mainHorizontalLinesStyle = mainHorizontalLinesStyle,
        _secondaryHorizontalLinesStyle = secondaryHorizontalLinesStyle,
        _secondaryHorizontalLines = secondaryHorizontalLines,
        super(
          entries,
          id: id,
          style: style,
        );

  final List<double> _secondaryHorizontalLines;
  final double _topHorizontalLine;
  final double _bottomHorizontalLine;
  final LineStyle? _secondaryHorizontalLinesStyle;
  final LineStyle? _mainHorizontalLinesStyle;

  @override
  SeriesPainter<DataSeries<Tick>> createPainter() => OscillatorLinePainter(
        this,
        bottomHorizontalLine: _bottomHorizontalLine,
        mainHorizontalLinesStyle: _mainHorizontalLinesStyle,
        secondaryHorizontalLines: _secondaryHorizontalLines,
        secondaryHorizontalLinesStyle: _secondaryHorizontalLinesStyle,
        topHorizontalLine: _topHorizontalLine,
      );
}
