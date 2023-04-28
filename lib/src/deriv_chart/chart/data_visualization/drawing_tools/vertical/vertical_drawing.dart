import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import '../drawing.dart';

/// Vertical drawing tool. A vertical is a vertical line defined by one point
/// that is infinite in both directions.
class VerticalDrawing extends Drawing {
  /// Initializes
  VerticalDrawing({
    required this.drawingPart,
    this.epoch = 0,
    this.yCoord = 0,
  });

  /// Part of a drawing: 'vertical'
  final String drawingPart;

  /// Starting epoch.
  final int epoch;

  /// Starting Y coordinates.
  final double yCoord;

  /// Paint
  @override
  void onPaint(
      Canvas canvas,
      Size size,
      ChartTheme theme,
      double Function(int x) epochToX,
      double Function(double y) quoteToY,
      DrawingToolConfig config,
      bool isDrawingDragged,
      DraggableEdgePoint draggableInitialPoint,
      {DraggableEdgePoint? draggableFinalPoint}) {
    final LineStyle lineStyle = config.toJson()['lineStyle'];
    final String pattern = config.toJson()['pattern'];

    draggableInitialPoint.draggedPosition = isDrawingDragged
        ? draggableInitialPoint.draggedPosition
        : Offset(epoch.toDouble(), yCoord);

    final double startQuoteToY = isDrawingDragged
        ? quoteToY(draggableInitialPoint.draggedPosition.dy)
        : quoteToY(yCoord);

    if (drawingPart == 'vertical') {
      final double xCoord = isDrawingDragged
          ? epochToX(draggableInitialPoint.draggedPosition.dx.toInt())
          : epochToX(epoch);

      final double startY = startQuoteToY - 1000,
          endingY = startQuoteToY + 1000;

      if (pattern == 'solid') {
        canvas.drawLine(
            Offset(xCoord, startY),
            Offset(xCoord, endingY),
            Paint()
              ..color = lineStyle.color
              ..strokeWidth = lineStyle.thickness);
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
      bool isDrawingDragged,
      DraggableEdgePoint draggableInitialPoint,
      {DraggableEdgePoint? draggableFinalPoint}) {
    final LineStyle lineStyle = config.toJson()['lineStyle'];

    draggableInitialPoint.draggedPosition = isDrawingDragged
        ? draggableInitialPoint.draggedPosition
        : Offset(epoch.toDouble(), yCoord);

    return isDrawingDragged
        ? position.dx >
                epochToX(draggableInitialPoint.draggedPosition.dx.toInt()) -
                    lineStyle.thickness -
                    3 &&
            position.dx <
                epochToX(draggableInitialPoint.draggedPosition.dx.toInt()) +
                    lineStyle.thickness +
                    3
        : position.dx > epochToX(epoch) - lineStyle.thickness - 3 &&
            position.dx < epochToX(epoch) + lineStyle.thickness + 3;
  }
}
