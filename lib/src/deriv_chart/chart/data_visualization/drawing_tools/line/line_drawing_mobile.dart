import 'dart:math';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/line/line_drawing_tool_label_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/vector.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/line_vector_drawing_mixin.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_dot.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'line_drawing_mobile.g.dart';

/// Line drawing tool. A line is a vector defined by two points that is
/// infinite in both directions.
@JsonSerializable()
class LineDrawingMobile extends Drawing with LineVectorDrawingMixin {
  /// Initializes
  LineDrawingMobile({
    required this.drawingPart,
    this.startEdgePoint = const EdgePoint(),
    this.endEdgePoint = const EdgePoint(),
    this.exceedStart = false,
    this.exceedEnd = false,
  });

  /// Initializes from JSON.
  factory LineDrawingMobile.fromJson(Map<String, dynamic> json) =>
      _$LineDrawingMobileFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LineDrawingMobileToJson(this)
    ..putIfAbsent(Drawing.classNameKey, () => nameKey);

  /// Key of drawing tool name property in JSON.
  static const String nameKey = 'LineDrawingMobile';

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

  Vector _vector = const Vector.zero();

  /// Keeps the latest position of the start and end point of drawing
  Point? _startPoint, _endPoint;

  /// Marker full size
  double markerFullSize = 10;

  /// Determines if markers should have a glowing effect.
  /// Glow is enabled on mobile platforms and disabled on web platforms.
  final bool shouldEnableMarkerGlow = !kIsWeb;

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
    config as LineDrawingToolConfigMobile;

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
      final double glowRadius =
          shouldEnableMarkerGlow ? lineStyle.markerRadius * 3 : 0;

      markerFullSize =
          shouldEnableMarkerGlow ? glowRadius * 2 : lineStyle.markerRadius * 2;

      if (endEdgePoint.epoch != 0 && endQuoteToY != 0) {
        /// Draw first point
        paintDotWithGlow(
          canvas,
          Offset(endXCoord, endQuoteToY),
          paint: paint.glowyCirclePaintStyle(lineStyle.color),
          dotRadius: lineStyle.markerRadius,
          hasGlow: shouldEnableMarkerGlow,
          glowRadius: glowRadius,
          visible: drawingData.shouldHighlight,
        );
      } else if (startEdgePoint.epoch != 0 && startQuoteToY != 0) {
        /// Draw second point
        paintDotWithGlow(
          canvas,
          Offset(startXCoord, startQuoteToY),
          paint: paint.glowyCirclePaintStyle(lineStyle.color),
          dotRadius: lineStyle.markerRadius,
          hasGlow: shouldEnableMarkerGlow,
          glowRadius: glowRadius,
          visible: drawingData.shouldHighlight,
        );
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
    config as LineDrawingToolConfigMobile;

    final LineStyle lineStyle = config.lineStyle;

    double startXCoord = _startPoint!.x;
    double startQuoteToY = _startPoint!.y;

    double endXCoord = _endPoint!.x;
    double endQuoteToY = _endPoint!.y;

    /// Check if start point clicked
    if (_startPoint!.isClicked(position, markerFullSize)) {
      setIsOverStartPoint(isOverPoint: true);
    } else {
      setIsOverStartPoint(isOverPoint: false);
    }

    /// Check if end point clicked
    if (_endPoint!.isClicked(position, markerFullSize)) {
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
        (_startPoint!.isClicked(position, markerFullSize) ||
            _endPoint!.isClicked(position, markerFullSize));
  }

  @override
  void onLabelPaint(
    Canvas canvas,
    Size size,
    ChartTheme theme,
    ChartConfig chartConfig,
    int Function(double x) epochFromX,
    double Function(double) quoteFromY,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
    DrawingToolConfig config,
    DrawingData drawingData,
    DataSeries<Tick> series,
  ) {
    super.onLabelPaint(canvas, size, theme, chartConfig, epochFromX, quoteFromY,
        epochToX, quoteToY, config, drawingData, series);

    final LineDrawingToolConfigMobile lineConfig =
        config as LineDrawingToolConfigMobile;

    if (_startPoint == null || _endPoint == null) {
      return;
    }

    if (drawingData.isSelected && drawingData.isDrawingFinished) {
      final LineDrawingToolLabelPainter? _lineDrawingToolLabelPainter =
          lineConfig.getLabelPainter(
        startPoint: _startPoint!,
        endPoint: _endPoint!,
      );

      _lineDrawingToolLabelPainter?.paint(canvas, size, chartConfig, epochFromX,
          quoteFromY, epochToX, quoteToY);
    }
  }
}
