import 'dart:ui';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/paint/paint_text.dart';
import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

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
        super(
          series,
          horizontalLines: secondaryHorizontalLines,
          horizontalLineStyle: secondaryHorizontalLinesStyle,
        );

  final double _topHorizontalLine;
  final double _bottomHorizontalLine;
  final LineStyle _mainHorizontalLinesStyle;

  Path _topHorizontalLinePath;
  Path _bottomHorizontalLinePath;

  /// Padding between lines.
  static const double padding = 4;

  /// Right margin.
  static const double rightMargin = 4;

  void _paintLabelBackground(
    Canvas canvas,
    Rect rect,
    LabelShape shape,
  ) {
    final Paint paint = Paint()
      ..color = _mainHorizontalLinesStyle.color
      ..style = PaintingStyle.fill
      ..strokeWidth = _mainHorizontalLinesStyle.thickness;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      paint,
    );
  }

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

    final HorizontalBarrierStyle style = HorizontalBarrierStyle(
      textStyle: TextStyle(
        fontSize: 10,
        color: calculateTextColor(_mainHorizontalLinesStyle.color),
      ),
    );

    final TextPainter topValuePainter = makeTextPainter(
      _topHorizontalLine.toStringAsFixed(0),
      style.textStyle,
    );

    final TextPainter bottomValuePainter = makeTextPainter(
      _bottomHorizontalLine.toStringAsFixed(0),
      style.textStyle,
    );

    final Rect topLabelArea = Rect.fromCenter(
      center: Offset(
          size.width - rightMargin - padding - topValuePainter.width / 2,
          quoteToY(_topHorizontalLine)),
      width: topValuePainter.width + padding * 2,
      height: style.labelHeight,
    );

    final Rect bottomLabelArea = Rect.fromCenter(
      center: Offset(
          size.width - rightMargin - padding - bottomValuePainter.width / 2,
          quoteToY(_bottomHorizontalLine)),
      width: bottomValuePainter.width + padding * 2,
      height: style.labelHeight,
    );

    _paintLabelBackground(canvas, bottomLabelArea, style.labelShape);
    _paintLabelBackground(canvas, topLabelArea, style.labelShape);
    paintWithTextPainter(
      canvas,
      painter: topValuePainter,
      anchor: topLabelArea.center,
    );
    paintWithTextPainter(
      canvas,
      painter: bottomValuePainter,
      anchor: bottomLabelArea.center,
    );
  }

  // TODO(mohammadamir-fs): add channel fill.
}
