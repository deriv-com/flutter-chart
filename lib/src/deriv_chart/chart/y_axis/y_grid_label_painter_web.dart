import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/deriv_chart/chart/y_axis/y_grid_label_painter.dart';
import 'package:flutter/material.dart';

/// A class that paints a lable on the Y axis of grid for web.
class YGridLabelPainterWeb extends YGridLabelPainter {
  /// Initialize
  YGridLabelPainterWeb({
    required super.gridLineQuotes,
    required super.pipSize,
    required super.quoteToCanvasY,
    required super.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final double quote in gridLineQuotes) {
      final double y = quoteToCanvasY(quote);

      paintText(
        canvas,
        text: quote.toStringAsFixed(pipSize),
        style: TextStyle(
          fontSize: style.yLabelStyle.fontSize,
          height: style.yLabelStyle.height,
          color: style.yLabelStyle.color,
        ),
        anchor: Offset(size.width - style.labelHorizontalPadding, y),
        anchorAlignment: Alignment.centerRight,
      );
    }
  }
}
