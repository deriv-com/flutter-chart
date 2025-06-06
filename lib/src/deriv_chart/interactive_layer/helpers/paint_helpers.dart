import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

/// Draws alignment guides (horizontal and vertical lines) for a single point
void drawPointAlignmentGuides(Canvas canvas, Size size, Offset pointOffset) {
  // Create a dashed paint style for the alignment guides
  final Paint guidesPaint = Paint()
    ..color = const Color(0x80FFFFFF) // Semi-transparent white
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  // Create paths for horizontal and vertical guides
  final Path horizontalPath = Path();
  final Path verticalPath = Path();

  // Draw horizontal and vertical guides from the point
  horizontalPath
    ..moveTo(0, pointOffset.dy)
    ..lineTo(size.width, pointOffset.dy);

  verticalPath
    ..moveTo(pointOffset.dx, 0)
    ..lineTo(pointOffset.dx, size.height);

  // Draw the dashed lines
  canvas
    ..drawPath(
      dashPath(horizontalPath,
          dashArray: CircularIntervalList<double>(<double>[5, 5])),
      guidesPaint,
    )
    ..drawPath(
      dashPath(verticalPath,
          dashArray: CircularIntervalList<double>(<double>[5, 5])),
      guidesPaint,
    );
}

/// Creates a dashed path from a regular path
Path dashPath(
  Path source, {
  required CircularIntervalList<double> dashArray,
}) {
  final Path dest = Path();
  for (final PathMetric metric in source.computeMetrics()) {
    double distance = 0;
    bool draw = true;
    while (distance < metric.length) {
      final double len = dashArray.next;
      if (draw) {
        dest.addPath(
          metric.extractPath(distance, distance + len),
          Offset.zero,
        );
      }
      distance += len;
      draw = !draw;
    }
  }
  return dest;
}

/// Draws a point for a given [EdgePoint].
void drawPoint(
  EdgePoint point,
  EpochToX epochToX,
  QuoteToY quoteToY,
  Canvas canvas,
  DrawingPaintStyle paintStyle,
  LineStyle lineStyle, {
  double radius = 5,
}) {
  canvas.drawCircle(
    Offset(epochToX(point.epoch), quoteToY(point.quote)),
    radius,
    paintStyle.glowyCirclePaintStyle(lineStyle.color),
  );
}

/// Draws a point for a given [Offset].
void drawPointOffset(
  Offset point,
  EpochToX epochToX,
  QuoteToY quoteToY,
  Canvas canvas,
  DrawingPaintStyle paintStyle,
  LineStyle lineStyle, {
  double radius = 5,
}) {
  canvas.drawCircle(
    point,
    radius,
    paintStyle.glowyCirclePaintStyle(lineStyle.color),
  );
}

/// Draws a point for an anchor point of a drawing tool with a glowy effect.
void drawFocusedCircle(
  DrawingPaintStyle paintStyle,
  LineStyle lineStyle,
  Canvas canvas,
  Offset offset,
  double outerCircleRadius,
  double innerCircleRadius,
) {
  final normalPaintStyle = paintStyle.glowyCirclePaintStyle(lineStyle.color);
  final glowyPaintStyle =
      paintStyle.glowyCirclePaintStyle(lineStyle.color.withOpacity(0.3));
  canvas
    ..drawCircle(
      offset,
      outerCircleRadius,
      glowyPaintStyle,
    )
    ..drawCircle(
      offset,
      innerCircleRadius,
      normalPaintStyle,
    );
}

/// Draws a point for an anchor point of a drawing tool with a glowy effect.
void drawPointsFocusedCircle(
  DrawingPaintStyle paintStyle,
  LineStyle lineStyle,
  Canvas canvas,
  Offset startOffset,
  double outerCircleRadius,
  double innerCircleRadius,
  Offset endOffset,
) {
  drawFocusedCircle(paintStyle, lineStyle, canvas, startOffset,
      outerCircleRadius, innerCircleRadius);
  drawFocusedCircle(paintStyle, lineStyle, canvas, endOffset, outerCircleRadius,
      innerCircleRadius);
}

/// A circular array for dash patterns
class CircularIntervalList<T> {
  /// Initializes [CircularIntervalList].
  CircularIntervalList(this._values);

  final List<T> _values;
  int _index = 0;

  /// Returns the next value in the circular list.
  T get next {
    if (_index >= _values.length) {
      _index = 0;
    }
    return _values[_index++];
  }
}

/// Draws a value rectangle with formatted price based on pip size
///
/// This draws a rounded rectangle with the formatted value inside it.
/// The value is formatted according to the provided pip size.
void drawValueLabel({
  required Canvas canvas,
  required QuoteToY quoteToY,
  required double value,
  required int pipSize,
  required Size size,
  required TextStyle textStyle,
  Color color = Colors.white,
  Color backgroundColor = Colors.transparent,
}) {
  // Calculate Y position based on the value
  final double yPosition = quoteToY(value);

  // Format the value according to pip size with proper decimal places
  final String formattedValue = value.toStringAsFixed(pipSize);

  // Create text painter to measure text dimensions
  final TextPainter textPainter =
      _getTextPainter(formattedValue, color, textStyle: textStyle)..layout();

  // Create rectangle with padding around the text
  final double rectWidth = textPainter.width + 24;
  const double rectHeight = 30; // Fixed height to match the image

  final double rectRight = size.width;
  final double rectLeft = rectRight - rectWidth;

  final Rect rect = Rect.fromLTRB(
    rectLeft,
    yPosition - rectHeight / 2,
    rectRight,
    yPosition + rectHeight / 2,
  );

  // Draw rounded rectangle
  final Paint rectPaint = Paint()
    ..color = backgroundColor
    ..style = PaintingStyle.fill;

  final Paint borderPaint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  // Draw the background and border
  final RRect roundedRect =
      RRect.fromRectAndRadius(rect, const Radius.circular(4));
  canvas
    ..drawRRect(roundedRect, rectPaint)
    ..drawRRect(roundedRect, borderPaint);

  // Draw the text centered in the rectangle
  textPainter.paint(
    canvas,
    Offset(
      rect.left + (rectWidth - textPainter.width) / 2,
      rect.top + (rectHeight - textPainter.height) / 2,
    ),
  );

  // hover for buttons
  // change cursor stle when hover over grab
}

/// Returns a [TextPainter] for the given formatted value and color.
TextPainter _getTextPainter(
  String formattedValue,
  Color color, {
  TextStyle textStyle = const TextStyle(
    color: Colors.white38,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  ),
}) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(
      text: formattedValue,
      style: textStyle,
    ),
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  );
  return textPainter;
}
