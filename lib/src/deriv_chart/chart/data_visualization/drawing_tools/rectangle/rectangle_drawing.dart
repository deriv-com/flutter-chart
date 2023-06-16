import 'dart:math';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/rectangle/rectangle_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
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

  /// enum including all possible drawing parts (marker,rectangle and drawing)
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
  final double _markerRadius = 10;

  /// Keeps the latest position of the start and end point of drawing
  Point? _startPoint, _endPoint;

  /// Store the created rectangle in this variable
  ///  (so it can be used for hitTest as well).
  Rect _rect = Rect.zero;

  /// Paint the rectangle
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

    final DrawingPatterns pattern = config.pattern;

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
            _markerRadius,
            drawingData.isSelected
                ? paint.glowyCirclePaintStyle(lineStyle.color)
                : paint.transparentCirclePaintStyle());
      } else if (startEpoch != 0 && startQuoteToY != 0) {
        /// Draw second point
        canvas.drawCircle(
            Offset(startXCoord, startQuoteToY),
            _markerRadius,
            drawingData.isSelected
                ? paint.glowyCirclePaintStyle(lineStyle.color)
                : paint.transparentCirclePaintStyle());
      }
    } else if (drawingPart == DrawingParts.rectangle) {
      if (pattern == DrawingPatterns.solid) {
        _rect = Rect.fromPoints(
            Offset(startXCoord, startQuoteToY), Offset(endXCoord, endQuoteToY));

        canvas
          ..drawRect(
              _rect,
              drawingData.isSelected
                  ? paint.glowyLinePaintStyle(
                      fillStyle.color.withOpacity(0.3), lineStyle.thickness)
                  : paint.fillPaintStyle(
                      fillStyle.color.withOpacity(0.3), lineStyle.thickness))
          ..drawRect(
              _rect, paint.strokeStyle(lineStyle.color, lineStyle.thickness));
      }
    }
  }

  /// Calculation for detemining whether a user's touch or click intersects
  /// with any of the painted areas on the screen,
  /// For any of the marker's clicked , the "isDragged" callback
  ///  function is called and allow the dragging of the points and changing the
  /// width/height of the drawing .If click is anywhere on rectangle, it allows the draging of
  /// the whole drawing
  ///
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

    /// inflate the rect to 2px so that the stroke is inclusive and
    /// can be detected
    final Rect _inflatedRect = _rect.inflate(2);

    // Calculate the difference between the start Point and the tap point.
    final double startDx = position.dx - startXCoord;
    final double startDy = position.dy - startQuoteToY;

    // Calculate the difference between the end Point and the tap point.
    final double endDx = position.dx - endXCoord;
    final double endDy = position.dy - endQuoteToY;

    // getting the distance of end point
    final double endPointDistance = sqrt(endDx * endDx + endDy * endDy);

    // getting the distance of start point
    final double startPointDistance =
        sqrt(startDx * startDx + startDy * startDy);

    /// Check if end point clicked
    if (_endPoint!.isClicked(position, _markerRadius)) {
      draggableEndPoint!.isDragged = true;
    }

    /// Check if start point clicked
    if (_startPoint!.isClicked(position, _markerRadius)) {
      draggableStartPoint.isDragged = true;
    }

    // If the distance (endpoint and startpoint) is less or equal to the
    //marker radius, it means the tap was inside the circle
    if (endPointDistance <= _markerRadius ||
        startPointDistance <= _markerRadius) {
      return true;
    }

    // check if the clicked position is inside the rectangle
    if (_inflatedRect.contains(position) && endEpoch != 0) {
      return true;
    }

    return false;
  }
}
