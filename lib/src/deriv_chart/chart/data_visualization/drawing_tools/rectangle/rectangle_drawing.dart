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
    this.startQuote = 0,
    this.endEpoch = 0,
    this.endQuote = 0,
  });

  /// instance of enum including all possible drawing parts(marker,rectangle)
  final DrawingParts drawingPart;

  /// Starting epoch.
  final int startEpoch;

  /// Starting Y coordinates.
  final double startQuote;

  /// Ending epoch.
  final int endEpoch;

  /// Ending Y coordinates.
  final double endQuote;

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
      startQuote,
      epochToX,
      quoteToY,
    );
    _endPoint = draggableEndPoint!.updatePosition(
      endEpoch,
      endQuote,
      epochToX,
      quoteToY,
    );

    final double startXCoord = _startPoint!.x;
    final double startQuoteToY = _startPoint!.y;

    final double endXCoord = _endPoint!.x;
    final double endYCoord = _endPoint!.y;

    if (drawingPart == DrawingParts.marker) {
      if (endEpoch != 0 && endYCoord != 0) {
        /// Draw first point
        canvas.drawCircle(
            Offset(endXCoord, endYCoord),
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
            Offset(startXCoord, startQuoteToY), Offset(endXCoord, endYCoord));

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
  /// For any of the marker's clicked , the "isDragged" flag is activated
  /// that allow the dragging of the points and changing the
  /// width/height of the drawing .If click is anywhere on rectangle, it allows the draging of
  /// the whole drawing
  @override
  bool hitTest(
    Offset position,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
    DrawingToolConfig config,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableEndPoint,
  }) {
    draggableEndPoint!.isDragged = false;
    draggableStartPoint.isDragged = false;

    /// inflate the rect to 2px so that the stroke is inclusive and
    /// can be detected
    final Rect _inflatedRect = _rect.inflate(2);

    /// Check if end point clicked
    if (_endPoint!.isClicked(position, _markerRadius)) {
      draggableEndPoint.isDragged = true;
    }

    /// Check if start point clicked
    if (_startPoint!.isClicked(position, _markerRadius)) {
      draggableStartPoint.isDragged = true;
    }

    return draggableStartPoint.isDragged ||
        draggableEndPoint.isDragged ||
        (_inflatedRect.contains(position) && endEpoch != 0);
  }
}
