import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:flutter/material.dart';

import '../paint/paint_text.dart';

class YGridPainter extends CustomPainter {
  YGridPainter({
    @required this.gridLineQuotes,
    @required this.pipSize,
    @required this.quoteToCanvasY,
    @required this.style,
  });

  final int pipSize;
  final List<double> gridLineQuotes;

  final double Function(double) quoteToCanvasY;

  final GridStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    for (final double quote in gridLineQuotes) {
      final double y = quoteToCanvasY(quote);

      final TextPainter labelPainter = makeTextPainter(
        quote.toStringAsFixed(pipSize),
        style.labelStyle,
      );

      canvas.drawLine(
        Offset(0, y),
        Offset(
          size.width - labelPainter.width - style.labelHorizontalPadding * 2,
          y,
        ),
        Paint()
          ..color = style.gridLineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = style.lineThickness,
      );

      paintWithTextPainter(
        canvas,
        painter: labelPainter,
        anchor: Offset(size.width - style.labelHorizontalPadding, y),
        anchorAlignment: Alignment.centerRight,
      );
    }
  }

  @override
  bool shouldRepaint(YGridPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(YGridPainter oldDelegate) => false;
}
