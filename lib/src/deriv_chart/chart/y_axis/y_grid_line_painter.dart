import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:flutter/material.dart';

/// A `CustomPainter` that paints the Y axis grids.

class YGridLinePainter extends CustomPainter {
  /// Initializes `CustomPainter` that paints the Y axis grids.

  YGridLinePainter({
    required this.gridLineQuotes,
    required this.quoteToCanvasY,
    required this.style,
    required this.labelWidth,
  });

  /// The list of quotes.
  final List<double> gridLineQuotes;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteToCanvasY;

  /// The style of chart's grid.
  final GridStyle style;

  /// The width of the grid line's label
  final double labelWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = style.gridLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.lineThickness;

    for (final double quote in gridLineQuotes) {
      final double y = quoteToCanvasY(quote);

      canvas.drawLine(
        Offset(0, y),
        Offset(
          size.width - labelWidth - style.labelHorizontalPadding * 2,
          y,
        ),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(YGridLinePainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(YGridLinePainter oldDelegate) => false;
}
