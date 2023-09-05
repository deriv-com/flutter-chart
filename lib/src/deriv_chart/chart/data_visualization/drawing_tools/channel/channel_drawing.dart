import 'package:deriv_chart/src/add_ons/drawing_tools_ui/channel/channel_drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
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

/// Channel drawing tool. A channel is 2 parallel lines that
/// created with 3 points.
class ChannelDrawing extends Drawing {
  /// Initializes
  ChannelDrawing({
    required this.drawingPart,
    this.startEdgePoint = const EdgePoint(),
    this.middleEdgePoint = const EdgePoint(),
    this.endEdgePoint = const EdgePoint(),
    this.isDrawingFinished = false,
  });

  /// Part of a drawing: 'marker' or 'line'
  final DrawingParts drawingPart;

  /// Starting point of drawing which is used as the start point of initial
  /// vector
  final EdgePoint startEdgePoint;

  /// Second point of drawing which is used to draw the end point of initial
  /// vector
  final EdgePoint middleEdgePoint;

  /// Ending point of drawing which is used to draw the second(final) vector
  final EdgePoint endEdgePoint;

  /// Marker radius.
  final double markerRadius = 10;

  /// Flag to show if drawing is finished.
  final bool isDrawingFinished;

  Vector _initialVector = const Vector.zero();
  Vector _finalVector = const Vector.zero();

  /// Keeps the latest position of the start and end point of drawing
  Point? _startPoint, _middlePoint, _endPoint;

  /// Returns the Parallelogram path
  Path getParallelogramPath(
    Vector startVector,
    Vector endVector,
  ) =>
      Path()
        ..moveTo(startVector.x0, startVector.y0)
        ..lineTo(startVector.x1, startVector.y1)
        ..lineTo(endVector.x1, endVector.y1)
        ..lineTo(endVector.x0, endVector.y0)
        ..close();

  /// Draw the shaded area between two vectors
  void drawParallelogram(
    Canvas canvas,
    ChannelDrawingToolConfig config,
    DrawingPaintStyle paint,
    Vector startVector,
    Vector endVector,
  ) {
    final LineStyle fillStyle = config.fillStyle;

    /// The path for the shaded area between two lines
    final Path path = getParallelogramPath(startVector, endVector);

    canvas.drawPath(
        path, paint.fillPaintStyle(fillStyle.color, fillStyle.thickness));
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
    DraggableEdgePoint? draggableMiddlePoint,
    DraggableEdgePoint? draggableEndPoint,
  }) {
    final DrawingPaintStyle paint = DrawingPaintStyle();

    /// Get the latest config of any drawing tool which is used to draw the line
    final ChannelDrawingToolConfig config =
        drawingData.config as ChannelDrawingToolConfig;

    final LineStyle lineStyle = config.lineStyle;
    final DrawingPatterns pattern = config.pattern;

    _startPoint = updatePositionCallback(startEdgePoint, draggableStartPoint);
    _middlePoint =
        updatePositionCallback(middleEdgePoint, draggableMiddlePoint!);
    _endPoint = updatePositionCallback(endEdgePoint, draggableEndPoint!);

    final double startXCoord = _startPoint!.x;
    final double startQuoteToY = _startPoint!.y;

    final double middleXCoord = _middlePoint!.x;
    final double middleQuoteToY = _middlePoint!.y;

    final double height = middleQuoteToY - _endPoint!.y;

    final double endXCoord = middleXCoord;
    final double endQuoteToY = middleQuoteToY - height;

    _initialVector = getLineVector(
      startXCoord,
      startQuoteToY,
      middleXCoord,
      middleQuoteToY,
    );

    _finalVector = getLineVector(
      endXCoord,
      endQuoteToY,
      startXCoord,
      startQuoteToY - height,
    );

    if (drawingPart == DrawingParts.marker) {
      if (endEdgePoint.epoch != 0 && endQuoteToY != 0) {
        /// Draw final point
        canvas.drawCircle(
            Offset(middleXCoord, middleQuoteToY - height),
            markerRadius,
            drawingData.isSelected
                ? paint.glowyCirclePaintStyle(lineStyle.color)
                : paint.transparentCirclePaintStyle());
      } else if (startEdgePoint.epoch != 0 && startQuoteToY != 0) {
        /// Draw first point
        canvas.drawCircle(
            Offset(startXCoord, startQuoteToY),
            markerRadius,
            drawingData.isSelected
                ? paint.glowyCirclePaintStyle(lineStyle.color)
                : paint.transparentCirclePaintStyle());
      } else if (middleEdgePoint.epoch != 0 && middleQuoteToY != 0) {
        /// Draw second point
        canvas.drawCircle(
            Offset(middleXCoord, middleQuoteToY),
            markerRadius,
            drawingData.isSelected
                ? paint.glowyCirclePaintStyle(lineStyle.color)
                : paint.transparentCirclePaintStyle());
      }
    } else if (drawingPart == DrawingParts.line) {
      if (endEdgePoint.epoch != 0 && endQuoteToY != 0) {
        /// Draw second line
        if (pattern == DrawingPatterns.solid) {
          canvas.drawLine(
            Offset(_finalVector.x0, _finalVector.y0),
            Offset(_finalVector.x1, _finalVector.y1),
            drawingData.isSelected
                ? paint.glowyLinePaintStyle(
                    lineStyle.color, lineStyle.thickness)
                : paint.linePaintStyle(lineStyle.color, lineStyle.thickness),
          );
        }
        drawParallelogram(canvas, config, paint, _initialVector, _finalVector);
      } else if (startEdgePoint.epoch != 0 && startQuoteToY != 0) {
        /// Draw first line
        if (pattern == DrawingPatterns.solid) {
          canvas.drawLine(
            Offset(_initialVector.x0, _initialVector.y0),
            Offset(_initialVector.x1, _initialVector.y1),
            drawingData.isSelected
                ? paint.glowyLinePaintStyle(
                    lineStyle.color, lineStyle.thickness)
                : paint.linePaintStyle(lineStyle.color, lineStyle.thickness),
          );
        }
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
    DraggableEdgePoint? draggableMiddlePoint,
    DraggableEdgePoint? draggableEndPoint,
    void Function({required bool isDragged})? setIsMiddlePointDragged,
    void Function({required bool isDragged})? setIsEndPointDragged,
  }) {
    setIsStartPointDragged(isDragged: false);
    setIsMiddlePointDragged!(isDragged: false);
    setIsEndPointDragged!(isDragged: false);

    final double middleXCoord = _middlePoint!.x;
    final double middleQuoteToY = _middlePoint!.y;

    final double height = middleQuoteToY - _endPoint!.y;

    final double endXCoord = middleXCoord;
    final double endQuoteToY = middleQuoteToY - height;

    /// Check if start point clicked
    if (_startPoint!.isClicked(position, markerRadius)) {
      setIsStartPointDragged(isDragged: true);
    }

    /// Check if middle point clicked
    if (_middlePoint!.isClicked(position, markerRadius)) {
      setIsMiddlePointDragged(isDragged: true);
    }

    /// Check if end point clicked, since the endPoint position is dependendat
    /// to middle point position, we need to check it differently
    final Point endPoint = Point(x: endXCoord, y: endQuoteToY);

    /// Check if end point clicked
    if (endPoint.isClicked(position, markerRadius)) {
      setIsEndPointDragged(isDragged: true);
    }

    /// Detect the area between 2 parallel lines
    final Path path = getParallelogramPath(_initialVector, _finalVector);

    return (isDrawingFinished && path.contains(position)) ||
        (draggableStartPoint.isDragged ||
            draggableMiddlePoint!.isDragged ||
            draggableEndPoint!.isDragged);
  }
}
