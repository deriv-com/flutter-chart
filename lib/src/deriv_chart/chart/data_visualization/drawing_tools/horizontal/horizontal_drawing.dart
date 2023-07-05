import 'package:deriv_chart/src/add_ons/drawing_tools_ui/distance_constants.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/horizontal/horizontal_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/paint_drawing_label.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';

/// Horizontal drawing tool.
/// A tool used to draw straight infinite horizontal line on the chart
class HorizontalDrawing extends Drawing {
  /// Initializes
  HorizontalDrawing({
    required this.drawingPart,
    required this.quoteFromCanvasY,
    this.epoch = 0,
    this.quote = 0,
  });

  /// Part of a drawing: 'horizontal'
  final DrawingParts drawingPart;

  /// Starting epoch.
  final int epoch;

  /// Starting quote
  final double quote;

  /// Keeps the latest position of the horizontal line
  Point? point;

  /// Conversion function for converting quote from chart's canvas' Y position.
  final double Function(double)? quoteFromCanvasY;

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
    final DrawingPaintStyle paint = DrawingPaintStyle();
    final HorizontalDrawingToolConfig config =
        drawingData.config as HorizontalDrawingToolConfig;

    final LineStyle lineStyle = config.lineStyle;
    final DrawingPatterns pattern = config.pattern;

    point = draggableStartPoint.updatePosition(
      epoch,
      quote,
      epochToX,
      quoteToY,
    );

    final double pointYCoord = point!.y;
    final double pointXCoord = point!.x;

    if (drawingPart == DrawingParts.line) {
      final double startX =
              pointXCoord - DrawingToolDistance.horizontalDistance,
          endingX = pointXCoord + DrawingToolDistance.horizontalDistance;

      if (pattern == DrawingPatterns.solid) {
        canvas.drawLine(
          Offset(startX, pointYCoord),
          Offset(endingX, pointYCoord),
          drawingData.isSelected
              ? paint.glowyLinePaintStyle(lineStyle.color, lineStyle.thickness)
              : paint.linePaintStyle(lineStyle.color, lineStyle.thickness),
        );
        paintDrawingLabel(canvas, size, pointYCoord, 'horizontal', theme,
            quoteFromY: quoteFromCanvasY);
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

    return position.dy > point!.y - lineStyle.thickness - 5 &&
        position.dy < point!.y + lineStyle.thickness + 5;
  }
}
