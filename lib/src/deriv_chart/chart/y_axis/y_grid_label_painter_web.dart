import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/deriv_chart/chart/y_axis/y_grid_label_painter.dart';
import 'package:flutter/material.dart';

/// A painter for drawing Y-axis grid labels in a web-based chart.
///
/// This painter extends [YGridLabelPainter] to provide custom drawing
/// functionality specific to web-based charts.
class YGridLabelPainterWeb extends YGridLabelPainter {
  /// Initialize
  YGridLabelPainterWeb({
    required super.gridLineQuotes,
    required super.pipSize,
    required super.quoteToCanvasY,
    required super.style,
    required super.topBoundQuote,
    required super.bottomBoundQuote,
    required super.topPadding,
    required super.bottomPadding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final TextStyle textStyle = TextStyle(
      fontSize: style.yLabelStyle.fontSize,
      height: style.yLabelStyle.height,
      color: style.yLabelStyle.color,
    );

    for (final double quote in gridLineQuotes) {
      final double y = quoteToCanvasY(quote);

      paintText(
        canvas,
        text: quote.toStringAsFixed(pipSize),
        style: textStyle,
        anchor: Offset(size.width - style.labelHorizontalPadding, y),
        anchorAlignment: Alignment.centerRight,
      );
    }
  }
}
