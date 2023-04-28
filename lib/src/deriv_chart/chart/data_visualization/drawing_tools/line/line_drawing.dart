import 'dart:math';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/vector.dart';
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
      bool isDrawingDragged,
      DraggableEdgePoint draggableInitialPoint,
      {DraggableEdgePoint? draggableFinalPoint}) {
    final LineStyle lineStyle = config.toJson()['lineStyle'];
    final String pattern = config.toJson()['pattern'];

    draggableInitialPoint.updatePosition(
      isDrawingDragged
          ? draggableInitialPoint.draggedPosition
          : Offset(startEpoch.toDouble(), startYCoord),
    );

    draggableFinalPoint!.updatePosition(
      isDrawingDragged
          ? draggableFinalPoint.draggedPosition
          : Offset(endEpoch.toDouble(), endYCoord),
    );

    final double startQuoteToY = isDrawingDragged
        ? quoteToY(draggableInitialPoint.draggedPosition.dy)
        : quoteToY(startYCoord);
    final double startXCoord = isDrawingDragged
        ? epochToX(draggableInitialPoint.draggedPosition.dx.toInt())
        : epochToX(startEpoch);

    final double endQuoteToY = isDrawingDragged
        ? quoteToY(draggableFinalPoint.draggedPosition.dy)
        : quoteToY(endYCoord);
    final double endXCoord = isDrawingDragged
        ? epochToX(draggableFinalPoint.draggedPosition.dx.toInt())
        : epochToX(endEpoch);

    if (drawingPart == 'marker') {
      if (endEpoch != 0 && endQuoteToY != 0) {
        canvas.drawCircle(Offset(endXCoord, endQuoteToY), markerRadius,
            Paint()..color = lineStyle.color);
      } else if (startEpoch != 0 && startQuoteToY != 0) {
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
      bool isDrawingDragged,
      DraggableEdgePoint draggableInitialPoint,
      {DraggableEdgePoint? draggableFinalPoint}) {
    draggableInitialPoint.updatePosition(
      isDrawingDragged
          ? draggableInitialPoint.draggedPosition
          : Offset(startEpoch.toDouble(), startYCoord),
    );

    draggableFinalPoint!.updatePosition(
      isDrawingDragged
          ? draggableFinalPoint.draggedPosition
          : Offset(endEpoch.toDouble(), endYCoord),
    );

    final double startQuoteToY = isDrawingDragged
        ? quoteToY(draggableInitialPoint.draggedPosition.dy)
        : quoteToY(startYCoord);
    final double endQuoteToY = isDrawingDragged
        ? quoteToY(draggableFinalPoint.draggedPosition.dy)
        : quoteToY(endYCoord);
    final double startXCoord = isDrawingDragged
        ? epochToX(draggableInitialPoint.draggedPosition.dx.toInt())
        : epochToX(startEpoch);
    final double endXCoord = isDrawingDragged
        ? epochToX(draggableFinalPoint.draggedPosition.dx.toInt())
        : epochToX(endEpoch);

    if (pow(startXCoord - position.dx, 2) +
            pow(startQuoteToY - position.dy, 2) <
        pow(markerRadius, 2)) {
      draggableInitialPoint.setIsEdgeDragged(isEdgeDragged: true);
    }

    if (pow(endXCoord - position.dx, 2) + pow(endQuoteToY - position.dy, 2) <
        pow(markerRadius, 2)) {
      draggableFinalPoint.setIsEdgeDragged(isEdgeDragged: true);
    }

    final double distance = ((endQuoteToY - startQuoteToY) * position.dx -
            (endXCoord - startXCoord) * position.dy +
            endXCoord * startQuoteToY -
            endQuoteToY * startXCoord) /
        sqrt(pow(endQuoteToY - startQuoteToY, 2) +
            pow(endXCoord - startXCoord, 2));

    return distance.abs() <= 10;
  }
}
