import 'package:deriv_chart/src/add_ons/drawing_tools_ui/continuous/continuous_drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/line/line_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/line/line_drawing.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';

/// Line drawing tool. A line is a vector defined by two points that is
/// infinite in both directions.
class ContinuousLineDrawing extends Drawing {
  /// Initializes
  ContinuousLineDrawing({
    required DrawingParts drawingPart,
    EdgePoint startEdgePoint = const EdgePoint(),
    EdgePoint endEdgePoint = const EdgePoint(),
    bool exceedStart = false,
    bool exceedEnd = false,
  }) : _lineDrawing = LineDrawing(
            drawingPart: drawingPart,
            startEdgePoint: startEdgePoint,
            endEdgePoint: endEdgePoint,
            exceedStart: exceedStart,
            exceedEnd: exceedEnd);

  final LineDrawing _lineDrawing;

  @override
  bool needsRepaint(
    int leftEpoch,
    int rightEpoch,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableEndPoint,
  }) =>
      _lineDrawing.needsRepaint(
        leftEpoch,
        rightEpoch,
        draggableStartPoint,
        draggableEndPoint: draggableEndPoint,
      );

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
    DraggableEdgePoint? draggableEndPoint,
  }) {
    final ContinuousDrawingToolConfig config =
        drawingData.config as ContinuousDrawingToolConfig;

    final LineStyle lineStyle = config.lineStyle;
    final DrawingPatterns pattern = config.pattern;

    _lineDrawing.onPaint(
        canvas,
        size,
        theme,
        epochToX,
        quoteToY,
        DrawingData(
          id: drawingData.id,
          config: LineDrawingToolConfig(lineStyle: lineStyle, pattern: pattern),
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
