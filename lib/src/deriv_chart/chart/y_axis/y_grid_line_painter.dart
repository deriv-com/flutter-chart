import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A `CustomPainter` that paints the Y axis grids.

class YGridLinePainter extends CustomPainter {
  /// Initializes `CustomPainter` that paints the Y axis grids.

  YGridLinePainter({
    required this.gridLineQuotes,
    required this.quoteToCanvasY,
    required this.style,
    required this.labelWidth,
    required this.topBoundQuote,
    required this.bottomBoundQuote,
    required this.topPadding,
    required this.bottomPadding,
  });

  /// The list of quotes.
  final List<double> gridLineQuotes;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteToCanvasY;

  /// The style of chart's grid.
  final GridStyle style;

  /// The width of the grid line's label
  final double labelWidth;

  /// The top bound quote used for repaint optimization.
  /// Note: This value is already captured by [quoteToCanvasY] closure
  /// and is tracked separately to detect when repainting is needed.
  final double topBoundQuote;

  /// The bottom bound quote used for repaint optimization.
  /// Note: This value is already captured by [quoteToCanvasY] closure
  /// and is tracked separately to detect when repainting is needed.
  final double bottomBoundQuote;

  /// The top padding used for repaint optimization.
  /// Note: This value is already captured by [quoteToCanvasY] closure
  /// and is tracked separately to detect when repainting is needed.
  final double topPadding;

  /// The bottom padding used for repaint optimization.
  /// Note: This value is already captured by [quoteToCanvasY] closure
  /// and is tracked separately to detect when repainting is needed.
  final double bottomPadding;

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
  bool shouldRepaint(YGridLinePainter oldDelegate) =>
      !listEquals(gridLineQuotes, oldDelegate.gridLineQuotes) ||
      style != oldDelegate.style ||
      labelWidth != oldDelegate.labelWidth ||
      topBoundQuote != oldDelegate.topBoundQuote ||
      bottomBoundQuote != oldDelegate.bottomBoundQuote ||
      topPadding != oldDelegate.topPadding ||
      bottomPadding != oldDelegate.bottomPadding;

  @override
  bool shouldRebuildSemantics(YGridLinePainter oldDelegate) => false;
}
