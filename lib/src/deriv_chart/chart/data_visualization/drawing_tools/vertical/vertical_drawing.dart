import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
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

  /// Keeps the latest position of the start of drawing
  Point? startPoint;

  /// Paint
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
    final DrawingToolConfig config = drawingData.config!;
    final LineStyle lineStyle = config.toJson()['lineStyle'];
    final String pattern = config.toJson()['pattern'];

    startPoint = draggableStartPoint.updatePosition(
      epoch,
      yCoord,
      epochToX,
      quoteToY,
    );

    final double xCoord = startPoint!.x;
    final double startQuoteToY = startPoint!.y;

    if (drawingPart == 'vertical') {
      final double startY = startQuoteToY - 10000,
          endingY = startQuoteToY + 10000;

      final Paint shadowPaint = Paint()
        ..color = lineStyle.color
        ..strokeWidth = lineStyle.thickness + 3
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 10);

      final Paint simplePaint = Paint()
        ..color = lineStyle.color
        ..strokeWidth = lineStyle.thickness;

      if (pattern == 'solid') {
        canvas.drawLine(
          Offset(xCoord, startY),
          Offset(xCoord, endingY),
          drawingData.isSelected ? shadowPaint : simplePaint,
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
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableEndPoint,
  }) {
    final LineStyle lineStyle = config.toJson()['lineStyle'];

    return position.dx > startPoint!.x - lineStyle.thickness - 5 &&
        position.dx < startPoint!.x + lineStyle.thickness + 5;
  }
}
