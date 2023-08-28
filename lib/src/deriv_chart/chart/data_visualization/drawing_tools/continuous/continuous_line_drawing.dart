import 'package:deriv_chart/src/add_ons/drawing_tools_ui/continuous/continuous_drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/line/line_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/line/line_drawing.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:json_annotation/json_annotation.dart';

part 'continuous_line_drawing.g.dart';

/// Line drawing tool. A line is a vector defined by two points that is
/// infinite in both directions.
@JsonSerializable()
class ContinuousLineDrawing extends Drawing {
  /// Initializes
  ContinuousLineDrawing({
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
          exceedEnd: exceedEnd,
        );

  /// Initializes from JSON.
  factory ContinuousLineDrawing.fromJson(Map<String, dynamic> json) =>
      _$ContinuousLineDrawingFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ContinuousLineDrawingToJson(this)
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

  /// Key of indicator name property in JSON.
  static const String nameKey = 'ContinuousLineDrawing';

  final LineDrawing _lineDrawing;

  /// Paint the line
  @override
  void onPaint(
    Canvas canvas,
    Size size,
    ChartTheme theme,
    int Function(double x) epochFromX,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
    DrawingToolConfig config,
    DrawingData drawingData,
    Point Function(
      EdgePoint edgePoint,
      DraggableEdgePoint draggableEdgePoint,
    ) updatePositionCallback,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableEndPoint,
  }) {
    config as ContinuousDrawingToolConfig;

    _lineDrawing.onPaint(
        canvas,
        size,
        theme,
        epochFromX,
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
    DraggableEdgePoint? draggableEndPoint,
    void Function({required bool isDragged})? setIsEndPointDragged,
  }) =>
      _lineDrawing.hitTest(position, epochToX, quoteToY, config,
          draggableStartPoint, setIsStartPointDragged,
          draggableEndPoint: draggableEndPoint,
          setIsEndPointDragged: setIsEndPointDragged);
}
