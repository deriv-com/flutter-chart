import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';

/// Base class for drawing tool label painter.
abstract class DrawingToolLabelPainter {
  /// Creates a DrawingLabelPainter.
  DrawingToolLabelPainter(this.config);

  /// The drawing tool config.
  final DrawingToolConfig config;

  /// Paints the label.
  void paint(
    Canvas canvas,
    Size size,
    ChartConfig chartConfig,
    int Function(double x) epochFromX,
    double Function(double y) quoteFromY,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
  );

  /// Paints background for the label.
  void drawLabelBackground(Canvas canvas, Rect rect, Paint paint,
      {double radius = 4}) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.elliptical(radius, 4)), paint);
  }

  /// Paints text on the canvas using TextPainter.
  void drawLabelWithBackground(
      Canvas canvas, Rect labelArea, Paint paint, TextPainter painter) {
    drawLabelBackground(canvas, labelArea, paint);
    paintWithTextPainter(canvas, painter: painter, anchor: labelArea.center);
  }
}
