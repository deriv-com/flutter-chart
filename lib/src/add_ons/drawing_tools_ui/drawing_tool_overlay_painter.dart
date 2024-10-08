import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// DrawingToolOverlayPainter is base class for drawing tool overlay painters.
abstract class DrawingToolOverlayPainter extends CustomPainter {
  /// Creates a DrawingToolOverlayPainter.
  DrawingToolOverlayPainter(
    this.config,
    this.quoteToY,
    this.epochToX,
    this.chartConfig,
  );

  /// Quote to Y conversion function.
  final QuoteToY quoteToY;

  /// Epoch to X conversion function.
  final EpochToX epochToX;

  /// Chart configuration.
  final ChartConfig chartConfig;

  /// Drawing tool configuration.
  final DrawingToolConfig config;

  @override
  void paint(Canvas canvas, Size size) {
    onPaint(
      canvas: canvas,
      size: size,
      config: config,
      epochToX: epochToX,
      quoteToY: quoteToY,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  /// Abstract method to be implemented by subclasses.
  void onPaint({
    required Canvas canvas,
    required Size size,
    required DrawingToolConfig config,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
  });

  /// Paints text on the canvas using TextPainter.
  void drawLabelWithBackground(
      Canvas canvas, Rect labelArea, Paint paint, TextPainter painter) {
    drawLabelBackground(canvas, labelArea, paint);
    paintWithTextPainter(canvas, painter: painter, anchor: labelArea.center);
  }

  /// Paints text on the canvas using TextPainter.
  void drawLabelBackground(Canvas canvas, Rect rect, Paint paint,
      {double radius = 4}) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.elliptical(radius, 4)), paint);
  }

  /// Paints text on the canvas using TextPainter.
  String formatEpochToDateTime(int epochMillis) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epochMillis);
    return '${DateFormat('yy-MM-dd HH:mm:ss').format(dateTime)} ${dateTime.timeZoneName}';
  }
}
