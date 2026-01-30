import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A class that paints a lable on the Y axis of grid.
class YGridLabelPainter extends CustomPainter {
  /// initializes a class that paints a lable on the Y axis of grid.
  YGridLabelPainter({
    required this.gridLineQuotes,
    required this.pipSize,
    required this.quoteToCanvasY,
    required this.style,
    required this.topBoundQuote,
    required this.bottomBoundQuote,
    required this.topPadding,
    required this.bottomPadding,
  });

  /// Number of digits after decimal point in price.
  final int pipSize;

  /// The list of quotes.
  final List<double> gridLineQuotes;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteToCanvasY;

  /// The style of chart's grid.

  final GridStyle style;

  /// The top bound quote (affects Y coordinate conversion).
  final double topBoundQuote;

  /// The bottom bound quote (affects Y coordinate conversion).
  final double bottomBoundQuote;

  /// The top padding (affects Y coordinate conversion).
  final double topPadding;

  /// The bottom padding (affects Y coordinate conversion).
  final double bottomPadding;

  @override
  void paint(Canvas canvas, Size size) {
    for (final double quote in gridLineQuotes) {
      final double y = quoteToCanvasY(quote);

      paintText(
        canvas,
        text: quote.toStringAsFixed(pipSize),
        style: style.yLabelStyle,
        anchor: Offset(size.width - style.labelHorizontalPadding, y),
        anchorAlignment: Alignment.centerRight,
      );
    }
  }

  @override
  bool shouldRepaint(YGridLabelPainter oldDelegate) =>
      !listEquals(gridLineQuotes, oldDelegate.gridLineQuotes) ||
      pipSize != oldDelegate.pipSize ||
      style != oldDelegate.style ||
      topBoundQuote != oldDelegate.topBoundQuote ||
      bottomBoundQuote != oldDelegate.bottomBoundQuote ||
      topPadding != oldDelegate.topPadding ||
      bottomPadding != oldDelegate.bottomPadding;

  @override
  bool shouldRebuildSemantics(YGridLabelPainter oldDelegate) => false;
}
