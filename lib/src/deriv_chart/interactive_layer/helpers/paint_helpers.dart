import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';

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
void drawPointsFocusedCircle(
    DrawingPaintStyle paintStyle,
    LineStyle lineStyle,
    Canvas canvas,
    Offset startOffset,
    double outerCircleRadius,
    double innerCircleRadius,
    Offset endOffset) {
  final normalPaintStyle = paintStyle.glowyCirclePaintStyle(lineStyle.color);
  final glowyPaintStyle =
      paintStyle.glowyCirclePaintStyle(lineStyle.color.withOpacity(0.3));
  canvas
    ..drawCircle(
      startOffset,
      outerCircleRadius,
      glowyPaintStyle,
    )
    ..drawCircle(
      startOffset,
      innerCircleRadius,
      normalPaintStyle,
    )
    ..drawCircle(
      endOffset,
      outerCircleRadius,
      glowyPaintStyle,
    )
    ..drawCircle(
      endOffset,
      innerCircleRadius,
      normalPaintStyle,
    );
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
