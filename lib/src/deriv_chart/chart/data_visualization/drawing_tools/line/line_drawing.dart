import 'dart:math';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/vector.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/line_vector_drawing_mixin.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'line_drawing.g.dart';

/// Line drawing tool. A line is a vector defined by two points that is
/// infinite in both directions.
@JsonSerializable()
class LineDrawing extends Drawing with LineVectorDrawingMixin {
  /// Initializes
  LineDrawing({
    required this.drawingPart,
    this.startEdgePoint = const EdgePoint(),
    this.endEdgePoint = const EdgePoint(),
    this.exceedStart = false,
    this.exceedEnd = false,
  });

  /// Initializes from JSON.
  factory LineDrawing.fromJson(Map<String, dynamic> json) =>
      _$LineDrawingFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LineDrawingToJson(this)
    ..putIfAbsent(Drawing.classNameKey, () => nameKey);

  /// Key of drawing tool name property in JSON.
  static const String nameKey = 'LineDrawing';

  /// Part of a drawing: 'marker' or 'line'
  final DrawingParts drawingPart;

  /// Starting point of drawing
  final EdgePoint startEdgePoint;

  /// Ending point of drawing
  final EdgePoint endEdgePoint;

  /// If the line pass the start point.
  final bool exceedStart;

  /// If the line pass the end point.
  final bool exceedEnd;

  /// Marker radius.
  final double markerRadius = 10;

  Vector _vector = const Vector.zero();

  /// Keeps the latest position of the start and end point of drawing
  Point? _startPoint, _endPoint;

// This condition will always return true since a LineDrawing,
// when created horizontally or near horizontal, will
// be positioned outside the chart's viewport.
  @override
  bool needsRepaint(
    int leftEpoch,
    int rightEpoch,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableMiddlePoint,
    DraggableEdgePoint? draggableEndPoint,
  }) =>
      true;

  /// Paint the line
  @override
  void onPaint(
    Canvas canvas,
    Size size,
    ChartTheme theme,
    int Function(double x) epochFromX,
    double Function(double) quoteFromY,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
    DrawingToolConfig config,
    DrawingData drawingData,
    DataSeries<Tick> series,
    Point Function(
      EdgePoint edgePoint,
      DraggableEdgePoint draggableEdgePoint,
    ) updatePositionCallback,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableMiddlePoint,
    DraggableEdgePoint? draggableEndPoint,
  }) {
    final DrawingPaintStyle paint = DrawingPaintStyle();

    /// Get the latest config of any drawing tool which is used to draw the line
    config as LineDrawingToolConfig;

    final LineStyle lineStyle = config.lineStyle;
    final DrawingPatterns pattern = config.pattern;
    final List<EdgePoint> edgePoints = config.edgePoints;

    _startPoint = updatePositionCallback(edgePoints.first, draggableStartPoint);
    if (edgePoints.length > 1) {
      _endPoint = updatePositionCallback(edgePoints.last, draggableEndPoint!);
    } else {
      _endPoint = updatePositionCallback(endEdgePoint, draggableEndPoint!);
    }

    final double startXCoord = _startPoint!.x;
    final double startQuoteToY = _startPoint!.y;

    final double endXCoord = _endPoint!.x;
    final double endQuoteToY = _endPoint!.y;

    if (drawingPart == DrawingParts.marker) {
      if (endEdgePoint.epoch != 0 && endQuoteToY != 0) {
        /// Draw first point
        canvas.drawCircle(
            Offset(endXCoord, endQuoteToY),
            markerRadius,
            drawingData.shouldHighlight
                ? paint.glowyCirclePaintStyle(lineStyle.color)
                : paint.transparentCirclePaintStyle());
      } else if (startEdgePoint.epoch != 0 && startQuoteToY != 0) {
        /// Draw second point
        canvas.drawCircle(
            Offset(startXCoord, startQuoteToY),
            markerRadius,
            drawingData.shouldHighlight
                ? paint.glowyCirclePaintStyle(lineStyle.color)
                : paint.transparentCirclePaintStyle());
      }
    } else if (drawingPart == DrawingParts.line) {
      _vector = getLineVector(
        startXCoord,
        startQuoteToY,
        endXCoord,
        endQuoteToY,
        exceedStart: exceedStart,
        exceedEnd: exceedEnd,
      );

      if (pattern == DrawingPatterns.solid) {
        canvas.drawLine(
          Offset(_vector.x0, _vector.y0),
          Offset(_vector.x1, _vector.y1),
          drawingData.shouldHighlight
              ? paint.glowyLinePaintStyle(lineStyle.color, lineStyle.thickness)
              : paint.linePaintStyle(lineStyle.color, lineStyle.thickness),
        );
      }
    }

    /// Draw the line barriers.
    // if (drawingData.isDrawingFinished && drawingData.shouldHighlight) {
    //   const double padding = 4;
    //   const double rightMargin = 4;
    //
    //   final Paint _paint = Paint()
    //     ..color = lineStyle.color
    //     ..strokeWidth = 1;
    //
    //   final Paint _rectPaint = Paint()
    //     ..style = PaintingStyle.fill
    //     ..color = lineStyle.color.withOpacity(0.2);
    //
    //   final HorizontalBarrierStyle style =
    //       series.style as HorizontalBarrierStyle? ??
    //           theme.horizontalBarrierStyle;
    //
    //   /// ------------------------------------------------------------------------
    //   /// Paint the quote labels and barrier on vertical axis
    //   /// ------------------------------------------------------------------------
    //
    //   // Create the start quote's label.
    //   final TextPainter startValuePainter = makeTextPainter(
    //     edgePoints.first.quote.toStringAsFixed(4),
    //     style.textStyle,
    //   );
    //
    //   // Create the end quote's label.
    //   final TextPainter endValuePainter = makeTextPainter(
    //     edgePoints.last.quote.toStringAsFixed(4),
    //     style.textStyle,
    //   );
    //
    //   // Create the rectangle background for the start quote's label.
    //   final Rect startLabelArea = Rect.fromCenter(
    //     center: Offset(
    //         size.width - rightMargin - padding - startValuePainter.width / 2,
    //         startQuoteToY),
    //     width: startValuePainter.width + padding * 2,
    //     height: style.labelHeight,
    //   );
    //
    //   // Create the rectangle background for the end quote's label.
    //   final Rect endLabelArea = Rect.fromCenter(
    //     center: Offset(
    //         size.width - rightMargin - padding - endValuePainter.width / 2,
    //         endQuoteToY),
    //     width: endValuePainter.width + padding * 2,
    //     height: style.labelHeight,
    //   );
    //
    //   // Create the horizontal barrier rectangle.
    //   final Rect horizontalBarrierRectangle = Rect.fromPoints(
    //     Offset(size.width - startLabelArea.width - padding, startQuoteToY),
    //     Offset(size.width, endQuoteToY),
    //   );
    //
    //   // Draw horizontal barrier layer between the two quotes.
    //   canvas.drawRect(horizontalBarrierRectangle, _rectPaint);
    //
    //   // Draw the start quote's label with background.
    //   _paintLabelBackground(canvas, startLabelArea, _paint);
    //   paintWithTextPainter(
    //     canvas,
    //     painter: startValuePainter,
    //     anchor: startLabelArea.center,
    //   );
    //
    //   // Draw the end quote's label with background.
    //   _paintLabelBackground(canvas, endLabelArea, _paint);
    //   paintWithTextPainter(
    //     canvas,
    //     painter: endValuePainter,
    //     anchor: endLabelArea.center,
    //   );
    //
    //   /// ------------------------------------------------------------------------
    //
    //   ///-------------------------------------------------------------------------
    //   /// Paint the epoch labels and barrier on horizontal axis
    //   /// ------------------------------------------------------------------------
    //
    //   // Date time formatted start epoch value.
    //   final String startEpochLabel = DateTime.fromMillisecondsSinceEpoch(
    //     edgePoints.first.epoch,
    //   ).toLocal().toString();
    //
    //   // Date time formatted end epoch value.
    //   final String endEpochLabel = DateTime.fromMillisecondsSinceEpoch(
    //     edgePoints.last.epoch,
    //   ).toLocal().toString();
    //
    //   // Create the start epoch label.
    //   final TextPainter startEpochPainter = makeTextPainter(
    //     startEpochLabel,
    //     style.textStyle,
    //   );
    //
    //   // Create the end epoch label.
    //   final TextPainter endEpochPainter = makeTextPainter(
    //     endEpochLabel,
    //     style.textStyle,
    //   );
    //
    //   // Create the rectangle background for the start epoch label.
    //   final Rect startEpochLabelArea = Rect.fromCenter(
    //     center: Offset(
    //         startXCoord, size.height - startEpochPainter.height - padding),
    //     width: startEpochPainter.width + padding * 2,
    //     height: style.labelHeight,
    //   );
    //
    //   // Create the rectangle background for the end epoch label.
    //   final Rect endEpochLabelArea = Rect.fromCenter(
    //     center:
    //         Offset(endXCoord, size.height - endEpochPainter.height - padding),
    //     width: endEpochPainter.width + padding * 2,
    //     height: style.labelHeight,
    //   );
    //
    //   // Create the vertical barrier rectangle.
    //   final Rect verticalBarrierRectangle = Rect.fromPoints(
    //     Offset(startEpochLabelArea.right,
    //         size.height - startEpochLabelArea.height - padding - 2),
    //     Offset(endEpochLabelArea.left, size.height - padding - 2),
    //   );
    //
    //   // Draw the start epoch label with background.
    //   _paintLabelBackground(canvas, startEpochLabelArea, _paint);
    //   paintWithTextPainter(
    //     canvas,
    //     painter: startEpochPainter,
    //     anchor: startEpochLabelArea.center,
    //   );
    //
    //   // Draw the end epoch label with background.
    //   _paintLabelBackground(canvas, endEpochLabelArea, _paint);
    //   paintWithTextPainter(
    //     canvas,
    //     painter: endEpochPainter,
    //     anchor: endEpochLabelArea.center,
    //   );
    //
    //   // Draw vertical barrier layer between the two epochs.
    //   canvas.drawRect(verticalBarrierRectangle, _rectPaint);
    //
    //   /// ------------------------------------------------------------------------
    // }
  }

  /// Calculation for detemining whether a user's touch or click intersects
  /// with any of the painted areas on the screen, for any of the edge points
  /// it will call "setIsEdgeDragged" callback function to determine which
  /// point is clicked
  @override
  bool hitTest(
    Offset position,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
    DrawingToolConfig config,
    DraggableEdgePoint draggableStartPoint,
    void Function({required bool isOverPoint}) setIsOverStartPoint, {
    DraggableEdgePoint? draggableMiddlePoint,
    DraggableEdgePoint? draggableEndPoint,
    void Function({required bool isOverPoint})? setIsOverMiddlePoint,
    void Function({required bool isOverPoint})? setIsOverEndPoint,
  }) {
    config as LineDrawingToolConfig;

    final LineStyle lineStyle = config.lineStyle;

    double startXCoord = _startPoint!.x;
    double startQuoteToY = _startPoint!.y;

    double endXCoord = _endPoint!.x;
    double endQuoteToY = _endPoint!.y;

    /// Check if start point clicked
    if (_startPoint!.isClicked(position, markerRadius)) {
      setIsOverStartPoint(isOverPoint: true);
    } else {
      setIsOverStartPoint(isOverPoint: false);
    }

    /// Check if end point clicked
    if (_endPoint!.isClicked(position, markerRadius)) {
      setIsOverEndPoint!(isOverPoint: true);
    } else {
      setIsOverEndPoint!(isOverPoint: false);
    }

    startXCoord = _vector.x0;
    startQuoteToY = _vector.y0;
    endXCoord = _vector.x1;
    endQuoteToY = _vector.y1;

    final double lineLength = sqrt(
        pow(endQuoteToY - startQuoteToY, 2) + pow(endXCoord - startXCoord, 2));

    /// Computes the distance between a point and a line which should be less
    /// than the line thickness + 6 to make sure the user can easily click on
    final double distance = ((endQuoteToY - startQuoteToY) * position.dx -
            (endXCoord - startXCoord) * position.dy +
            endXCoord * startQuoteToY -
            endQuoteToY * startXCoord) /
        sqrt(pow(endQuoteToY - startQuoteToY, 2) +
            pow(endXCoord - startXCoord, 2));

    final double xDistToStart = position.dx - startXCoord;
    final double yDistToStart = position.dy - startQuoteToY;

    /// Limit the detection to start and end point of the line
    final double dotProduct = (xDistToStart * (endXCoord - startXCoord) +
            yDistToStart * (endQuoteToY - startQuoteToY)) /
        lineLength;

    final bool isWithinRange = dotProduct > 0 && dotProduct < lineLength;

    return isWithinRange && distance.abs() <= lineStyle.thickness + 6 ||
        (_startPoint!.isClicked(position, markerRadius) ||
            _endPoint!.isClicked(position, markerRadius));
  }

  /// Paints a background for the label text.
  void _paintLabelBackground(Canvas canvas, Rect rect, Paint paint,
      {double radius = 4}) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.elliptical(radius, 4)),
      paint,
    );
  }
}
