import 'package:deriv_chart/src/add_ons/drawing_tools_ui/distance_constants.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/horizontal/horizontal_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/paint_drawing_label.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'horizontal_drawing.g.dart';

/// Horizontal drawing tool.
/// A tool used to draw straight infinite horizontal line on the chart
@JsonSerializable()
class HorizontalDrawing extends Drawing {
  /// Initializes
  HorizontalDrawing({
    required this.drawingPart,
    required this.chartConfig,
    required this.edgePoint,
  });

  /// Initializes from JSON.
  factory HorizontalDrawing.fromJson(Map<String, dynamic> json) =>
      _$HorizontalDrawingFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HorizontalDrawingToJson(this)
    ..putIfAbsent(Drawing.classNameKey, () => nameKey);

  /// Key of drawing tool name property in JSON.
  static const String nameKey = 'HorizontalDrawing';

  /// Chart config to get pipSize
  final ChartConfig? chartConfig;

  /// Part of a drawing: 'horizontal'
  final DrawingParts drawingPart;

  /// Starting point of drawing
  final EdgePoint edgePoint;

  /// Keeps the latest position of the horizontal line
  Point? startPoint;

  // TODO(NA): Return true when the horizontal drawing is in the epoch range.
  @override
  bool needsRepaint(
    int leftEpoch,
    int rightEpoch,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableMiddlePoint,
    DraggableEdgePoint? draggableEndPoint,
  }) =>
      true;

  /// Paint
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
    config as HorizontalDrawingToolConfig;

    final LineStyle lineStyle = config.lineStyle;
    final DrawingPatterns pattern = config.pattern;
    final List<EdgePoint> edgePoints = config.edgePoints;

    startPoint = updatePositionCallback(edgePoints.first, draggableStartPoint);

    final double pointYCoord = startPoint!.y;
    final double pointXCoord = startPoint!.x;

    final double startX = pointXCoord - DrawingToolDistance.horizontalDistance,
        endingX = pointXCoord + DrawingToolDistance.horizontalDistance;

    if (pattern == DrawingPatterns.solid) {
      canvas.drawLine(
        Offset(startX, pointYCoord),
        Offset(endingX, pointYCoord),
        drawingData.shouldHighlight
            ? paint.glowyLinePaintStyle(lineStyle.color, lineStyle.thickness)
            : paint.linePaintStyle(lineStyle.color, lineStyle.thickness),
      );
      if (config.enableLabel) {
        paintDrawingLabel(
          canvas,
          size,
          pointYCoord,
          'horizontal',
          theme,
          chartConfig!,
          quoteFromY: quoteFromY,
          color: lineStyle.color,
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
    void Function({required bool isOverPoint}) setIsOverStartPoint, {
    DraggableEdgePoint? draggableMiddlePoint,
    DraggableEdgePoint? draggableEndPoint,
    void Function({required bool isOverPoint})? setIsOverMiddlePoint,
    void Function({required bool isOverPoint})? setIsOverEndPoint,
  }) {
    config as HorizontalDrawingToolConfig;

    final LineStyle lineStyle = config.lineStyle;

    return position.dy > startPoint!.y - lineStyle.thickness - 5 &&
        position.dy < startPoint!.y + lineStyle.thickness + 5;
  }
}
