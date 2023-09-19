import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/line/line_drawing.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ray_line_drawing.g.dart';

/// Ray drawing tool. Ray is a vector defined by two points that is
/// infinite in end direction.
@JsonSerializable()
class RayLineDrawing extends Drawing {
  /// Initializes
  RayLineDrawing({
    required this.drawingPart,
    this.startEdgePoint = const EdgePoint(),
    this.endEdgePoint = const EdgePoint(),
    this.exceedStart = false,
    this.exceedEnd = false,
  }) : _lineDrawing = LineDrawing(
            drawingPart: drawingPart,
            startEdgePoint: startEdgePoint,
            endEdgePoint: endEdgePoint,
            exceedStart: exceedStart,
            exceedEnd: exceedEnd);

  /// Initializes from JSON.
  factory RayLineDrawing.fromJson(Map<String, dynamic> json) =>
      _$RayLineDrawingFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RayLineDrawingToJson(this)
    ..putIfAbsent(Drawing.classNameKey, () => nameKey);

  /// Drawing part.
  final DrawingParts drawingPart;

  /// Start edge point.
  final EdgePoint startEdgePoint;

  /// End edge point.
  final EdgePoint endEdgePoint;

  /// Whether the start point is exceeded.
  final bool exceedStart;

  /// Whether the end point is exceeded.
  final bool exceedEnd;

  /// Key of drawing tool name property in JSON.
  static const String nameKey = 'RayLineDrawing';

  final LineDrawing _lineDrawing;

  @override
  bool needsRepaint(
    int leftEpoch,
    int rightEpoch,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableMiddlePoint,
    DraggableEdgePoint? draggableEndPoint,
  }) =>
      _lineDrawing.needsRepaint(
        leftEpoch,
        rightEpoch,
        draggableStartPoint,
        draggableMiddlePoint: draggableMiddlePoint,
        draggableEndPoint: draggableEndPoint,
      );

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
    config as RayDrawingToolConfig;

    _lineDrawing.onPaint(
        canvas,
        size,
        theme,
        epochFromX,
        quoteFromY,
        epochToX,
        quoteToY,
        LineDrawingToolConfig(
          configId: config.configId,
          drawingData: config.drawingData,
          lineStyle: config.lineStyle,
          pattern: config.pattern,
          edgePoints: config.edgePoints,
        ),
        DrawingData(
          id: drawingData.id,
          drawingParts: drawingData.drawingParts,
          isDrawingFinished: drawingData.isDrawingFinished,
          isSelected: drawingData.isSelected,
        ),
        series,
        updatePositionCallback,
        draggableStartPoint,
        draggableEndPoint: draggableEndPoint);
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
    config as RayDrawingToolConfig;

    final LineStyle lineStyle = config.lineStyle;
    final DrawingPatterns pattern = config.pattern;

    return _lineDrawing.hitTest(
        position,
        epochToX,
        quoteToY,
        LineDrawingToolConfig(lineStyle: lineStyle, pattern: pattern),
        draggableStartPoint,
        setIsStartPointDragged,
        draggableEndPoint: draggableEndPoint,
        setIsEndPointDragged: setIsEndPointDragged);
  }
}
