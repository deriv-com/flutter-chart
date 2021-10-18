import 'package:deriv_chart/deriv_chart.dart';

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
    LineStyle? style,
    String? id,
    LineStyle? secondaryHorizontalLinesStyle,
    LineStyle? mainHorizontalLinesStyle,
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
  // ignore: unused_field
  final LineStyle? _mainHorizontalLinesStyle;

  @override
  SeriesPainter<DataSeries<Tick>> createPainter() => OscillatorLinePainter(
        this,
        bottomHorizontalLine: _bottomHorizontalLine,
        secondaryHorizontalLines: _secondaryHorizontalLines,
        secondaryHorizontalLinesStyle: _secondaryHorizontalLinesStyle,
        topHorizontalLine: _topHorizontalLine,
      );
}
