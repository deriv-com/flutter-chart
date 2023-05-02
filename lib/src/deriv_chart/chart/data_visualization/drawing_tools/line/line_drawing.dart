import 'dart:math';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/vector.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import '../drawing.dart';

/// Line drawing tool. A line is a vector defined by two points that is
/// infinite in both directions.
class LineDrawing extends Drawing {
  /// Initializes
  LineDrawing({
    required this.drawingPart,
    this.startEpoch = 0,
    this.startYCoord = 0,
    this.endEpoch = 0,
    this.endYCoord = 0,
  });

  /// Part of a drawing: 'marker' or 'line'
  final String drawingPart;

  /// Starting epoch.
  final int startEpoch;

  /// Starting Y coordinates.
  final double startYCoord;

  /// Ending epoch.
  final int endEpoch;

  /// Ending Y coordinates.
  final double endYCoord;

  /// Marker radius.
  final double markerRadius = 4;

  Vector _vector = Vector(x0: 0, y0: 0, x1: 0, y1: 0);

  ///Vector of the line
  Vector getLineVector(double startXCoord, double startQuoteToY,
      double endXCoord, double endQuoteToY) {
    Vector vec = Vector(
      x0: startXCoord,
      y0: startQuoteToY,
      x1: endXCoord,
      y1: endQuoteToY,
    );
    if (vec.x0 > vec.x1) {
      vec = Vector(
        x0: endXCoord,
        y0: endQuoteToY,
        x1: startXCoord,
        y1: startQuoteToY,
      );
    }

    final double earlier = vec.x0 - 1000;
    final double later = vec.x1 + 1000;

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

  /// Paint the line
  @override
  void onPaint(
    Canvas canvas,
    Size size,
    ChartTheme theme,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
    DrawingToolConfig config,
    DraggableEdgePoint draggableStartPoint, {
    required bool isDrawingDragged,
    DraggableEdgePoint? draggableEndPoint,
  }) {
    final LineStyle lineStyle = config.toJson()['lineStyle'];
    final String pattern = config.toJson()['pattern'];

    final Point startPoint = draggableStartPoint.updatePosition(
      startEpoch,
      startYCoord,
      epochToX,
      quoteToY,
    );
    final Point endPoint = draggableEndPoint!.updatePosition(
      endEpoch,
      endYCoord,
      epochToX,
      quoteToY,
    );

    final double startXCoord = startPoint.x;
    final double startQuoteToY = startPoint.y;

    final double endXCoord = endPoint.x;
    final double endQuoteToY = endPoint.y;

    if (drawingPart == 'marker') {
      if (endEpoch != 0 && endQuoteToY != 0) {
        /// Draw first point
        canvas.drawCircle(Offset(endXCoord, endQuoteToY), markerRadius,
            Paint()..color = lineStyle.color);
      } else if (startEpoch != 0 && startQuoteToY != 0) {
        /// Draw second point
        canvas.drawCircle(Offset(startXCoord, startQuoteToY), markerRadius,
            Paint()..color = lineStyle.color);
      }
    } else if (drawingPart == 'line') {
      _vector =
          getLineVector(startXCoord, startQuoteToY, endXCoord, endQuoteToY);

      if (pattern == 'solid') {
        canvas.drawLine(
            Offset(_vector.x0, _vector.y0),
            Offset(_vector.x1, _vector.y1),
            Paint()
              ..color = lineStyle.color
              ..strokeWidth = lineStyle.thickness);
      }
    }
  }

  /// Calculation for detemining whether a user's touch or click intersects
  /// with any of the painted areas on the screen
  @override
  bool hitTest(
    Offset position,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
    DrawingToolConfig config,
    DraggableEdgePoint draggableStartPoint, {
    required bool isDrawingDragged,
    DraggableEdgePoint? draggableEndPoint,
  }) {
    final LineStyle lineStyle = config.toJson()['lineStyle'];

    final Point startPoint = draggableStartPoint.updatePosition(
      startEpoch,
      startYCoord,
      epochToX,
      quoteToY,
    );
    final Point endPoint = draggableEndPoint!.updatePosition(
      endEpoch,
      endYCoord,
      epochToX,
      quoteToY,
    );

    final double startXCoord = startPoint.x;
    final double startQuoteToY = startPoint.y;

    final double endXCoord = endPoint.x;
    final double endQuoteToY = endPoint.y;

    /// Check if start point clicked
    if (startPoint.isClicked(position, markerRadius)) {
      draggableStartPoint.setIsEdgeDragged(isEdgeDragged: true);
    }

    /// Check if end point clicked
    if (endPoint.isClicked(position, markerRadius)) {
      draggableEndPoint.setIsEdgeDragged(isEdgeDragged: true);
    }

    /// Computes the distance between a point and a line which should be less
    /// than the line thickness + 6 to make sure the user can easily click on
    final double distance = ((endQuoteToY - startQuoteToY) * position.dx -
            (endXCoord - startXCoord) * position.dy +
            endXCoord * startQuoteToY -
            endQuoteToY * startXCoord) /
        sqrt(pow(endQuoteToY - startQuoteToY, 2) +
            pow(endXCoord - startXCoord, 2));

    return distance.abs() <= lineStyle.thickness + 6;
  }
}
