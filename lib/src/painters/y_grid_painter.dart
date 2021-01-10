import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:flutter/material.dart';

import '../paint/paint_text.dart';

/// A `CustomPainter` that paints the Y axis grids.
class YGridPainter extends CustomPainter {
  /// Initializes a `CustomPainter` that paints the Y axis grids.
  YGridPainter({
    @required this.gridLineQuotes,
    @required this.pipSize,
    @required this.quoteToCanvasY,
    @required this.style,
  });

  /// Number of digits after decimal point in price.
  final int pipSize;

  /// The list of quotes;
  final List<double> gridLineQuotes;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteToCanvasY;

  /// The style of chart's grid.'
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
