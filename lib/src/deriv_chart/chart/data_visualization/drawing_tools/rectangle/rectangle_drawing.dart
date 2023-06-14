import 'dart:math';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/rectangle/rectangle_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';

/// Rectangle drawing tool.
class RectangleDrawing extends Drawing {
  /// Initializes
  RectangleDrawing({
    required this.drawingPart,
    this.startEpoch = 0,
    this.startYCoord = 0,
    this.endEpoch = 0,
    this.endYCoord = 0,
  });

  /// Part of a drawing: 'marker' or 'line'
  final DrawingParts drawingPart;

  /// Starting epoch.
  final int startEpoch;

  /// Starting Y coordinates.
  final double startYCoord;

  /// Ending epoch.
  final int endEpoch;

  /// Ending Y coordinates.
  final double endYCoord;

  /// Marker radius.
  final double markerRadius = 10;

  /// Keeps the latest position of the start and end point of drawing
  Point? _startPoint, _endPoint;

  /// Store the created rectangle in this variable
  ///  (so it can be used for hitTest as well).
  Rect rect = Rect.zero;

  /// Paint the line
  @override
  void onPaint(
    Canvas canvas,
    Size size,
    ChartTheme theme,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
    DrawingData drawingData,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableEndPoint,
  }) {
    final DrawingPaintStyle paint = DrawingPaintStyle();
    final RectangleDrawingToolConfig config =
        drawingData.config as RectangleDrawingToolConfig;

    final LineStyle lineStyle = config.lineStyle;

    final LineStyle fillStyle = config.fillStyle;

    final String pattern = config.pattern;

    _startPoint = draggableStartPoint.updatePosition(
      startEpoch,
      startYCoord,
      epochToX,
      quoteToY,
    );
    _endPoint = draggableEndPoint!.updatePosition(
      endEpoch,
      endYCoord,
      epochToX,
      quoteToY,
    );

    final double startXCoord = _startPoint!.x;
    final double startQuoteToY = _startPoint!.y;

    final double endXCoord = _endPoint!.x;
    final double endQuoteToY = _endPoint!.y;

    if (drawingPart == DrawingParts.marker) {
      if (endEpoch != 0 && endQuoteToY != 0) {
        /// Draw first point
        canvas.drawCircle(
            Offset(endXCoord, endQuoteToY),
            markerRadius,
            drawingData.isSelected
                ? paint.glowyCirclePaintStyle(lineStyle.color)
                : paint.transparentCirclePaintStyle());
      } else if (startEpoch != 0 && startQuoteToY != 0) {
        /// Draw second point
        canvas.drawCircle(
            Offset(startXCoord, startQuoteToY),
            markerRadius,
            drawingData.isSelected
                ? paint.glowyCirclePaintStyle(lineStyle.color)
                : paint.transparentCirclePaintStyle());
      }
    } else if (drawingPart == DrawingParts.rectangle) {
      if (pattern == 'solid') {
        rect = Rect.fromPoints(
            Offset(startXCoord, startQuoteToY), Offset(endXCoord, endQuoteToY));

        canvas.drawRect(
            rect,
            drawingData.isSelected
                ? paint.glowyLinePaintStyle(
                    fillStyle.color.withOpacity(0.3), lineStyle.thickness)
                : paint.fillPaintStyle(
                    fillStyle.color.withOpacity(0.3), lineStyle.thickness));
      }
    }
  }

  /// Calculation for detemining whether a user's touch or click intersects
  /// with any of the painted areas on the screen, for any of the edge points
  /// it will call "setIsEdgeDragged" callback function to determine which
  /// point clicked
  @override
  bool hitTest(
    Offset position,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
    DrawingToolConfig config,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableEndPoint,
  }) {
    final LineStyle lineStyle = config.toJson()['lineStyle'];
    final double startXCoord = _startPoint!.x;
    final double startQuoteToY = _startPoint!.y;

    final double endXCoord = _endPoint!.x;
    final double endQuoteToY = _endPoint!.y;

    /// Check if start point clicked
    if (_startPoint!.isClicked(position, markerRadius)) {
      draggableStartPoint.isDragged = true;
    }

    /// Check if end point clicked
    if (_endPoint!.isClicked(position, markerRadius)) {
      draggableEndPoint!.isDragged = true;
    }

    if (endEpoch == 0) {
      return false;
    }

    final double distance = ((endQuoteToY - startQuoteToY) * position.dx -
            (endXCoord - startXCoord) * position.dy +
            endXCoord * startQuoteToY -
            endQuoteToY * startXCoord) /
        sqrt(pow(endQuoteToY - startQuoteToY, 2) +
            pow(endXCoord - startXCoord, 2));

    // check if the clicked position is inside the rectangle
    if (rect.contains(position) && endEpoch != 0) {
      return true;
    }

    if (distance.abs() <= lineStyle.thickness + 6) {
      return true;
    }
    return false;
  }
}
