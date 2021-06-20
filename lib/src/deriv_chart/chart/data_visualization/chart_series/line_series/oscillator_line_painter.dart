import 'dart:ui';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/helper_functions.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import '../../chart_data.dart';
import '../data_series.dart';
import 'line_painter.dart';

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
  })  : _mainHorizontalLinesStyle =
            mainHorizontalLinesStyle ?? const LineStyle(color: Colors.blueGrey),
        _topHorizontalLine = topHorizontalLine,
        _secondaryHorizontalLines = secondaryHorizontalLines,
        _secondaryHorizontalLinesStyle = secondaryHorizontalLinesStyle ??
            const LineStyle(color: Colors.blueGrey),
        _bottomHorizontalLine = bottomHorizontalLine,
        super(
          series,
        );

  final double _topHorizontalLine;
  final double _bottomHorizontalLine;
  final LineStyle _mainHorizontalLinesStyle;
  final List<double> _secondaryHorizontalLines;
  final LineStyle _secondaryHorizontalLinesStyle;
  Path _topHorizontalLinePath;
  Path _bottomHorizontalLinePath;

  /// Padding between lines.
  static const double padding = 4;

  /// Right margin.
  static const double rightMargin = 4;

  @override
  void onPaintData(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  ) {
    _paintHorizontalLines(canvas, quoteToY, size);

    super.onPaintData(canvas, size, epochToX, quoteToY, animationInfo);
  }

  void _paintHorizontalLines(Canvas canvas, QuoteToY quoteToY, Size size) {
    _paintSecondaryHorizontalLines(canvas, quoteToY, size);

    const HorizontalBarrierStyle textStyle =
        HorizontalBarrierStyle(textStyle: TextStyle(fontSize: 10));
    final Paint paint = Paint()
      ..color = _mainHorizontalLinesStyle.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _mainHorizontalLinesStyle.thickness;

    _topHorizontalLinePath = Path();
    _bottomHorizontalLinePath = Path();

    if (_topHorizontalLine != null) {
      _topHorizontalLinePath
        ..moveTo(0, quoteToY(_topHorizontalLine))
        ..lineTo(
            size.width -
                labelWidth(_bottomHorizontalLine, textStyle.textStyle,
                    chartConfig.pipSize),
            quoteToY(_topHorizontalLine));

      canvas.drawPath(_topHorizontalLinePath, paint);
    }

    if (_bottomHorizontalLine != null) {
      _bottomHorizontalLinePath
        ..moveTo(0, quoteToY(_bottomHorizontalLine))
        ..lineTo(
            size.width -
                labelWidth(_topHorizontalLine, textStyle.textStyle,
                    chartConfig.pipSize),
            quoteToY(_bottomHorizontalLine));

      canvas.drawPath(_bottomHorizontalLinePath, paint);
    }

    _paintLabels(size, quoteToY, canvas);
  }

  void _paintSecondaryHorizontalLines(
      Canvas canvas, QuoteToY quoteToY, Size size) {
    final LineStyle horizontalLineStyle =
        _secondaryHorizontalLinesStyle ?? theme.lineStyle ?? const LineStyle();
    final Paint horizontalLinePaint = Paint()
      ..color = horizontalLineStyle.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = horizontalLineStyle.thickness;

    for (final double line in _secondaryHorizontalLines) {
      canvas.drawLine(Offset(0, quoteToY(line)),
          Offset(size.width, quoteToY(line)), horizontalLinePaint);
    }
  }

  void _paintLabels(Size size, QuoteToY quoteToY, Canvas canvas) {
    final HorizontalBarrierStyle style = HorizontalBarrierStyle(
      textStyle: TextStyle(fontSize: 10, color: theme.base01Color),
    );

    if (_topHorizontalLine != null) {
      final TextPainter topValuePainter = makeTextPainter(
        _topHorizontalLine.toStringAsFixed(0),
        style.textStyle,
      );
      final Rect topLabelArea = Rect.fromCenter(
        center: Offset(
            size.width - rightMargin - padding - topValuePainter.width / 2,
            quoteToY(_topHorizontalLine)),
        width: topValuePainter.width + padding * 2,
        height: style.labelHeight,
      );
      paintWithTextPainter(
        canvas,
        painter: topValuePainter,
        anchor: topLabelArea.center,
      );
    }

    if (_bottomHorizontalLine != null) {
      final TextPainter bottomValuePainter = makeTextPainter(
        _bottomHorizontalLine.toStringAsFixed(0),
        style.textStyle,
      );

      final Rect bottomLabelArea = Rect.fromCenter(
        center: Offset(
            size.width - rightMargin - padding - bottomValuePainter.width / 2,
            quoteToY(_bottomHorizontalLine)),
        width: bottomValuePainter.width + padding * 2,
        height: style.labelHeight,
      );

      paintWithTextPainter(
        canvas,
        painter: bottomValuePainter,
        anchor: bottomLabelArea.center,
      );
    }
  }

  // TODO(mohammadamir-fs): add channel fill.
}
