import 'dart:ui' as ui;

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
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';

/// Horizontal drawing tool.
/// A tool used to draw straight infinite horizontal line on the chart
class HorizontalDrawing extends Drawing {
  /// Initializes
  HorizontalDrawing({
    required this.drawingPart,
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

  /// function to add quote labels to the vertical drawing tool
  void addLabel(
      Canvas canvas, Size size, Function quoteFromY, double pointYCoord) {
    const double width = 50; // Width of the rectangle
    const double height = 20; // Height of the rectangle

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: quoteFromY(pointYCoord).toStringAsFixed(3),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(
        maxWidth: size.width,
      );

    final ui.Offset offset = Offset(size.width - 44, pointYCoord - 5);
    final Rect rect = Rect.fromCenter(
        center: Offset(size.width - 25, pointYCoord),
        width: width,
        height: height);

    canvas.drawRect(
      rect,
      Paint()..color = const Color(0xFFCC2E3D),
    );
    textPainter.paint(canvas, offset);
  }

  /// Paint
  @override
  void onPaint(
    Canvas canvas,
    Size size,
    ChartTheme theme,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
    double Function(double y) quoteFromY,
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
      if (pattern == DrawingPatterns.solid) {
        final double startX =
                pointXCoord - DrawingToolDistance.horizontalDistance,
            endingX = pointXCoord + DrawingToolDistance.horizontalDistance;

        canvas.drawLine(
          Offset(startX, pointYCoord),
          Offset(endingX, pointYCoord),
          drawingData.isSelected
              ? paint.glowyLinePaintStyle(lineStyle.color, lineStyle.thickness)
              : paint.linePaintStyle(lineStyle.color, lineStyle.thickness),
        );
        addLabel(canvas, size, quoteFromY, pointYCoord);
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
