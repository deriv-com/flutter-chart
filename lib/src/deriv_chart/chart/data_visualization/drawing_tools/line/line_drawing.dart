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

    final returnValue =
        isWithinRange && distance.abs() <= lineStyle.thickness + 6 ||
            (_startPoint!.isClicked(position, markerRadius) ||
                _endPoint!.isClicked(position, markerRadius));

    return returnValue;
  }
}
