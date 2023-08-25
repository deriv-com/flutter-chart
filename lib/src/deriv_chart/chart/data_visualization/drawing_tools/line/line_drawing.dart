import 'dart:math';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/line/line_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/extensions.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/vector.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';

/// Line drawing tool. A line is a vector defined by two points that is
/// infinite in both directions.
class LineDrawing extends Drawing {
  /// Initializes
  LineDrawing({
    required this.drawingPart,
    this.startEdgePoint = const EdgePoint(),
    this.endEdgePoint = const EdgePoint(),
    this.exceedStart = false,
    this.exceedEnd = false,
  });

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

  /// Vector of the line
  Vector getLineVector(
    double startXCoord,
    double startQuoteToY,
    double endXCoord,
    double endQuoteToY,
  ) {
    Vector vec = Vector(
      x0: startXCoord,
      y0: startQuoteToY,
      x1: endXCoord,
      y1: endQuoteToY,
    );

    late double earlier, later;
    if (exceedEnd && !exceedStart) {
      earlier = vec.x0;
      if (vec.x0 > vec.x1) {
        later = vec.x1 - 1000;
      } else {
        later = vec.x1 + 1000;
      }
    }
    if (exceedStart && !exceedEnd) {
      later = vec.x1;

      if (vec.x0 > vec.x1) {
        earlier = vec.x0 + 1000;
      } else {
        earlier = vec.x0 - 1000;
      }
    }

    if (exceedStart && exceedEnd) {
      if (vec.x0 > vec.x1) {
        vec = Vector(
          x0: endXCoord,
          y0: endQuoteToY,
          x1: startXCoord,
          y1: startQuoteToY,
        );
      }

      earlier = vec.x0 - 1000;
      later = vec.x1 + 1000;
    }

    if (!exceedEnd && !exceedStart) {
      if (vec.x0 > vec.x1) {
        vec = Vector(
          x0: endXCoord,
          y0: endQuoteToY,
          x1: startXCoord,
          y1: startQuoteToY,
        );
      }
      earlier = vec.x0;
      later = vec.x1;
    }

    final double startY = getYIntersection(vec, earlier) ?? 0,
        endingY = getYIntersection(vec, later) ?? 0,
        startX = earlier,
        endingX = later;

    return Vector(
      x0: startX,
      y0: startY,
      x1: endingX,
      y1: endingY,
    );
  }

  @override
  bool needsRepaint(
    int leftEpoch,
    int rightEpoch,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableEndPoint,
  }) {
    // TODO(NA): This is a temporary implementation to demonstrate this
    //  improvement to check if line drawing needs repainting or not.
    //  it only considers the draggable edge points. in the real implementation
    //  we should also consider the line as well.
    if (draggableStartPoint.isOnViewPortRange(leftEpoch, rightEpoch) ||
        (draggableEndPoint == null ||
            draggableEndPoint.isOnViewPortRange(leftEpoch, rightEpoch))) {
      return true;
    }

    return false;
  }

  /// Paint the line
  @override
  void onPaint(
    Canvas canvas,
    Size size,
    ChartTheme theme,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
    DrawingData drawingData,
    Point Function(
      EdgePoint edgePoint,
      DraggableEdgePoint draggableEdgePoint,
    ) updatePositionCallback,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableEndPoint,
  }) {
    final DrawingPaintStyle paint = DrawingPaintStyle();

    /// Get the latest config of any drawing tool which is used to draw the line
    final LineDrawingToolConfig config =
        drawingData.config as LineDrawingToolConfig;

    final LineStyle lineStyle = config.lineStyle;
    final DrawingPatterns pattern = config.pattern;

    _startPoint = updatePositionCallback(startEdgePoint, draggableStartPoint);
    _endPoint = updatePositionCallback(endEdgePoint, draggableEndPoint!);

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
            drawingData.isSelected
                ? paint.glowyCirclePaintStyle(lineStyle.color)
                : paint.transparentCirclePaintStyle());
      } else if (startEdgePoint.epoch != 0 && startQuoteToY != 0) {
        /// Draw second point
        canvas.drawCircle(
            Offset(startXCoord, startQuoteToY),
            markerRadius,
            drawingData.isSelected
                ? paint.glowyCirclePaintStyle(lineStyle.color)
                : paint.transparentCirclePaintStyle());
      }
    } else if (drawingPart == DrawingParts.line) {
      _vector = getLineVector(
        startXCoord,
        startQuoteToY,
        endXCoord,
        endQuoteToY,
      );

      if (pattern == DrawingPatterns.solid) {
        canvas.drawLine(
          Offset(_vector.x0, _vector.y0),
          Offset(_vector.x1, _vector.y1),
          drawingData.isSelected
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
    void Function({required bool isDragged}) setIsStartPointDragged, {
    DraggableEdgePoint? draggableEndPoint,
    void Function({required bool isDragged})? setIsEndPointDragged,
  }) {
    setIsStartPointDragged(isDragged: false);
    setIsEndPointDragged!(isDragged: false);

    final LineStyle lineStyle = config.toJson()['lineStyle'];

    double startXCoord = _startPoint!.x;
    double startQuoteToY = _startPoint!.y;

    double endXCoord = _endPoint!.x;
    double endQuoteToY = _endPoint!.y;

    /// Check if start point clicked
    if (_startPoint!.isClicked(position, markerRadius)) {
      setIsStartPointDragged(isDragged: true);
    }

    /// Check if end point clicked
    if (_endPoint!.isClicked(position, markerRadius)) {
      setIsEndPointDragged(isDragged: true);
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
        (draggableStartPoint.isDragged || draggableEndPoint!.isDragged);
  }
}
