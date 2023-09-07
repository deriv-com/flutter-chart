import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/channel/channel_drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/fibfan/fibfan_drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/line/line_drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/ray/ray_line_drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/trend/trend_drawing.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';

import 'continuous/continuous_line_drawing.dart';
import 'vertical/vertical_drawing.dart';

/// Base class to draw a particular drawing
abstract class Drawing {
  /// Initializes [Drawing].
  const Drawing();

  /// Initializes from JSON.
  /// For restoring drawings add them to the switch statement.
  factory Drawing.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey(classNameKey)) {
      throw ArgumentError.value(json, 'json', 'Missing indicator name.');
    }

    switch (json[classNameKey]) {
      case ChannelDrawing.nameKey:
        return ChannelDrawing.fromJson(json);
      case ContinuousLineDrawing.nameKey:
        return ContinuousLineDrawing.fromJson(json);
      case FibfanDrawing.nameKey:
        return FibfanDrawing.fromJson(json);
      case LineDrawing.nameKey:
        return LineDrawing.fromJson(json);
      case RayLineDrawing.nameKey:
        return RayLineDrawing.fromJson(json);
      case TrendDrawing.nameKey:
        return TrendDrawing.fromJson(json);
      case VerticalDrawing.nameKey:
        return VerticalDrawing.fromJson(json);

      default:
        throw ArgumentError.value(json, 'json', 'Invalid indicator name.');
    }
  }

  /// Creates a concrete drawing tool from JSON.
  Map<String, dynamic> toJson();

  /// Key of drawing tool name property in JSON.
  static const String classNameKey = 'class_name_key';

  /// Paint
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
    DraggableEdgePoint? draggableMiddlePoint,
    DraggableEdgePoint? draggableEndPoint,
  });

  /// Calculates whether a user's touch or click intersects
  /// with any of the painted areas on the screen
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
  });
}
