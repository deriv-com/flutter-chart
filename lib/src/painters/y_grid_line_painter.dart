import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:flutter/material.dart';

class YGridLinePainter extends CustomPainter {
  YGridLinePainter({
    @required this.gridLineQuotes,
    @required this.quoteToCanvasY,
    @required this.style,
    @required this.labelWidth,
  });

  final List<double> gridLineQuotes;
  final double Function(double) quoteToCanvasY;
  final GridStyle style;
  final double labelWidth;

  @override
  void paint(Canvas canvas, Size size) {
    for (final double quote in gridLineQuotes) {
      final double y = quoteToCanvasY(quote);

      canvas.drawLine(
        Offset(0, y),
        Offset(
          size.width - labelWidth - style.labelHorizontalPadding * 2,
          y,
        ),
        Paint()
          ..color = style.gridLineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = style.lineThickness,
      );
    }
  }

  @override
  bool shouldRepaint(YGridLinePainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(YGridLinePainter oldDelegate) => false;
}
