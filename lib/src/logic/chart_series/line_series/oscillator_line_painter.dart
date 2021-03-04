import 'dart:ui';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// A [LinePainter] for painting line with two main top and bottom horizontal lines.
/// They can have more than 2 lines.
class OscillatorLinePainter extends LinePainter {
  /// Initializes an Oscillator line painter.
  OscillatorLinePainter(
    DataSeries<Tick> series, {
    double topHorizontalLine,
    double bottomHorizontalLine,
    LineStyle mainHorizontalLinesStyle,
    LineStyle secondaryHorizontalLinesStyle,
    List<double> secondaryHorizontalLines = const <double>[],
  })  : _mainHorizontalLinesStyle = mainHorizontalLinesStyle,
        _topHorizontalLine = topHorizontalLine,
        _bottomHorizontalLine = bottomHorizontalLine,
        super(series,
            horizontalLines: secondaryHorizontalLines,
            horizontalLineStyle: secondaryHorizontalLinesStyle);

  final double _topHorizontalLine;
  final double _bottomHorizontalLine;
  final LineStyle _mainHorizontalLinesStyle;

  Path _topHorizontalLinePath;
  Path _bottomHorizontalLinePath;

  @override
  void paintHorizontalLines(Canvas canvas, QuoteToY quoteToY, Size size) {
    super.paintHorizontalLines(canvas, quoteToY, size);

    final Paint paint = Paint()
      ..color = _mainHorizontalLinesStyle.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _mainHorizontalLinesStyle.thickness;

    _topHorizontalLinePath = Path();
    _bottomHorizontalLinePath = Path();

    _topHorizontalLinePath.moveTo(0, quoteToY(_topHorizontalLine));
    _bottomHorizontalLinePath.moveTo(0, quoteToY(_bottomHorizontalLine));

    _topHorizontalLinePath.lineTo(size.width, quoteToY(_topHorizontalLine));
    _bottomHorizontalLinePath.lineTo(
        size.width, quoteToY(_bottomHorizontalLine));

    canvas
      ..drawPath(_topHorizontalLinePath, paint)
      ..drawPath(_bottomHorizontalLinePath, paint);
  }

  // TODO(mohammadamir-fs): add channel fill.
}
