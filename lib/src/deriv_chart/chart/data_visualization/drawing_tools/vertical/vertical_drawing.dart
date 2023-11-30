import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/vertical/vertical_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/extensions.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/paint_drawing_label.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

/// Vertical drawing tool. A vertical is a vertical line defined by one point
/// that is infinite in both directions.
class VerticalDrawing extends Drawing {
  /// Initializes
  VerticalDrawing({
    required this.drawingPart,
    required this.chartConfig,
    required this.edgePoint,
    required this.epochFromX,
  });

  /// Chart config to get pipSize
  final ChartConfig? chartConfig;

  /// Get epoch from x.
  int Function(double x)? epochFromX;

  /// Part of a drawing: 'vertical'
  final DrawingParts drawingPart;

  /// Starting point of drawing
  final EdgePoint edgePoint;

  /// Keeps the latest position of the start of drawing
  Point? startPoint;

  @override
  bool needsRepaint(
    int leftEpoch,
    int rightEpoch,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableEndPoint,
  }) =>
      draggableStartPoint.isInViewPortRange(
        leftEpoch,
        rightEpoch,
      );

  /// Paint
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
    final VerticalDrawingToolConfig config =
        drawingData.config as VerticalDrawingToolConfig;

    final LineStyle lineStyle = config.lineStyle;
    final DrawingPatterns pattern = config.pattern;

    startPoint = updatePositionCallback(edgePoint, draggableStartPoint);

    final double xCoord = startPoint!.x;
    final double startQuoteToY = startPoint!.y;
    if (drawingPart == DrawingParts.line) {
      final double startY = startQuoteToY - 10000,
          endingY = startQuoteToY + 10000;

      if (pattern == DrawingPatterns.solid) {
        canvas.drawLine(
          Offset(xCoord, startY),
          Offset(xCoord, endingY),
          drawingData.isSelected
              ? paint.glowyLinePaintStyle(lineStyle.color, lineStyle.thickness)
              : paint.linePaintStyle(lineStyle.color, lineStyle.thickness),
        );
        paintDrawingLabel(
          canvas,
          size,
          xCoord,
          'vertical',
          theme,
          chartConfig!,
          epochFromX: epochFromX,
        );
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
    DraggableEdgePoint draggableStartPoint,
    void Function({required bool isDragged}) setIsStartPointDragged, {
    DraggableEdgePoint? draggableMiddlePoint,
    DraggableEdgePoint? draggableEndPoint,
    void Function({required bool isDragged})? setIsMiddlePointDragged,
    void Function({required bool isDragged})? setIsEndPointDragged,
  }) {
    config as VerticalDrawingToolConfig;

    final LineStyle lineStyle = config.lineStyle;

    return position.dx > startPoint!.x - lineStyle.thickness - 5 &&
        position.dx < startPoint!.x + lineStyle.thickness + 5;
  }
}
