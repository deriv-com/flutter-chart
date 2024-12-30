import 'dart:math';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/rectangle/rectangle_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/extensions/extensions.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rectangle_drawing.g.dart';

/// Rectangle drawing tool.
@JsonSerializable()
class RectangleDrawing extends Drawing {
  /// Initializes
  RectangleDrawing({
    required this.drawingPart,
    this.startEdgePoint = const EdgePoint(),
    this.endEdgePoint = const EdgePoint(),
  });

  /// Initializes from JSON.
  factory RectangleDrawing.fromJson(Map<String, dynamic> json) =>
      _$RectangleDrawingFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RectangleDrawingToJson(this)
    ..putIfAbsent(Drawing.classNameKey, () => nameKey);

  /// Key of drawing tool name property in JSON.
  static const String nameKey = 'RectangleDrawing';

  /// Instance of enum including all possible drawing parts(marker,rectangle)
  final DrawingParts drawingPart;

  /// Marker radius.
  final double _markerRadius = 10;

  /// Keeps the latest position of the start and end point of drawing
  Point? _startPoint, _endPoint;

  /// Store the created rectangle in this variable
  ///  (so it can be used for hitTest as well).
  Rect _rect = Rect.zero;

  /// Store the starting X Coordinate
  double startXCoord = 0;

  /// Store the starting Y Coordinate
  double startYCoord = 0;

  /// Store the ending X Coordinate
  double endXCoord = 0;

  /// Store the ending Y Coordinate
  double endYCoord = 0;

  ///  Starting point of drawing
  EdgePoint startEdgePoint;

  /// Ending point of drawing
  EdgePoint endEdgePoint;

  /// Function to check if the clicked position (Offset) is on
  /// boundary of the rectangle
  bool _isClickedOnRectangleBoundary(Rect rect, Offset position) {
    /// Width of the rectangle line
    const double lineWidth = 3;
    const int touchTolerance = 10;

    final List<Rect> rectangleLinesBoundaries = <Rect>[
      Rect.fromLTWH(
        rect.left - touchTolerance,
        rect.top - touchTolerance,
        rect.width + touchTolerance * 2,
        lineWidth + touchTolerance * 2,
      ),
      Rect.fromLTWH(
        rect.left - touchTolerance,
        rect.top - touchTolerance,
        lineWidth + touchTolerance * 2,
        rect.height + touchTolerance * 2,
      ),
      Rect.fromLTWH(
        rect.right - lineWidth - touchTolerance * 2,
        rect.top - touchTolerance,
        lineWidth + touchTolerance * 2,
        rect.height + touchTolerance * 2,
      ),
      Rect.fromLTWH(
        rect.left - touchTolerance,
        rect.bottom - lineWidth - touchTolerance * 2,
        rect.width + touchTolerance * 2 + 2,
        lineWidth + touchTolerance * 2 + 2,
      ),
    ];

    return rectangleLinesBoundaries
        .any((Rect lineBound) => lineBound.inflate(2).contains(position));
  }

  /// Paint the rectangle
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
    config as RectangleDrawingToolConfig;

    final LineStyle lineStyle = config.lineStyle;
    final LineStyle fillStyle = config.fillStyle;
    final DrawingPatterns pattern = config.pattern;
    final List<EdgePoint> edgePoints = config.edgePoints;

    _startPoint = updatePositionCallback(edgePoints.first, draggableStartPoint);
    if (edgePoints.length > 1) {
      _endPoint = updatePositionCallback(edgePoints.last, draggableEndPoint!);
    } else {
      _endPoint = updatePositionCallback(endEdgePoint, draggableEndPoint!);
    }

    startXCoord = _startPoint!.x;
    startYCoord = _startPoint!.y;

    endXCoord = _endPoint!.x;
    endYCoord = _endPoint!.y;

    if (drawingPart == DrawingParts.marker) {
      if (endEdgePoint.epoch != 0 && endYCoord != 0) {
        /// Draw first marker
        canvas.drawCircle(
            Offset(endXCoord, endYCoord),
            _markerRadius,
            drawingData.shouldHighlight
                ? paint.glowyCirclePaintStyle(lineStyle.color)
                : paint.transparentCirclePaintStyle());
      } else if (startEdgePoint.epoch != 0 && startYCoord != 0) {
        /// Draw second marker
        canvas.drawCircle(
            Offset(startXCoord, startYCoord),
            _markerRadius,
            drawingData.shouldHighlight
                ? paint.glowyCirclePaintStyle(lineStyle.color)
                : paint.transparentCirclePaintStyle());
      }
    } else if (drawingPart == DrawingParts.rectangle) {
      if (pattern == DrawingPatterns.solid) {
        _rect = Rect.fromPoints(
            Offset(startXCoord, startYCoord), Offset(endXCoord, endYCoord));

        canvas
          ..drawRect(
              _rect,
              drawingData.shouldHighlight
                  ? paint.glowyLinePaintStyle(
                      fillStyle.color.withValues(alpha: 0.3),
                      lineStyle.thickness)
                  : paint.fillPaintStyle(fillStyle.color.withValues(alpha: 0.3),
                      lineStyle.thickness))
          ..drawRect(
              _rect, paint.strokeStyle(lineStyle.color, lineStyle.thickness));
      }
    }
  }

  /// Calculation for detemining whether a user's touch or click intersects
  /// with any of the painted lines on the screen,
  /// the drawing is selected on clicking on any boundary(line) and markers of
  /// the drawing
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
    // Calculate the difference between the start marker and the tap point.
    final double startDx = position.dx - startXCoord;
    final double startDy = position.dy - startYCoord;

    // Calculate the difference between the end marker and the tap point.
    final double endDx = position.dx - endXCoord;
    final double endDy = position.dy - endYCoord;

    // Getting the distance from end marker
    final double endPointDistance = sqrt(endDx * endDx + endDy * endDy);

    // Getting the distance from start marker
    final double startPointDistance =
        sqrt(startDx * startDx + startDy * startDy);

    /// Check if end point clicked
    if (endPointDistance <= _markerRadius) {
      setIsOverEndPoint!(isOverPoint: true);
    } else {
      setIsOverEndPoint!(isOverPoint: false);
    }

    /// Check if start point clicked
    if (startPointDistance <= _markerRadius) {
      setIsOverStartPoint(isOverPoint: true);
    } else {
      setIsOverStartPoint(isOverPoint: false);
    }

    return draggableStartPoint.isDragged ||
        draggableEndPoint!.isDragged ||
        (_isClickedOnRectangleBoundary(_rect, position) &&
            endEdgePoint.epoch != 0);
  }

  // TODO(NA): return when the rectangle drawing is inside the epoch range.
  @override
  bool needsRepaint(
    int leftEpoch,
    int rightEpoch,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableMiddlePoint,
    DraggableEdgePoint? draggableEndPoint,
  }) =>
      draggableStartPoint.isInViewPortRange(leftEpoch, rightEpoch) ||
      (draggableEndPoint?.isInViewPortRange(leftEpoch, rightEpoch) ?? true);
}
