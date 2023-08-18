import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/vector.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/line/line_drawing.dart';
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
  factory Drawing.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey(classNameKey)) {
      throw ArgumentError.value(json, 'json', 'Missing indicator name.');
    }

    switch (json[classNameKey]) {
      case ContinuousLineDrawing.nameKey:
        return ContinuousLineDrawing.fromJson(json);
      case LineDrawing.nameKey:
        return LineDrawing.fromJson(json);
      case VerticalDrawing.nameKey:
        return VerticalDrawing.fromJson(json);
      case TrendDrawing.nameKey:
        return TrendDrawing.fromJson(json);

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
    DrawingData drawingData,
    Point Function(
      EdgePoint edgePoint,
      DraggableEdgePoint draggableEdgePoint,
    ) updatePositionCallback,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableEndPoint,
  });

  /// Calculates y intersection based on vector points.
  double? getYIntersection(Vector vector, double x) {
    final double x1 = vector.x0, x2 = vector.x1, x3 = x, x4 = x;
    final double y1 = vector.y0, y2 = vector.y1, y3 = 0, y4 = 10000;
    final double denominator = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1);
    final double numerator = (x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3);

    double mua = numerator / denominator;
    if (denominator == 0) {
      if (numerator == 0) {
        mua = 1;
      } else {
        return null;
      }
    }

    final double y = y1 + mua * (y2 - y1);
    return y;
  }

  /// Calculates whether a user's touch or click intersects
  /// with any of the painted areas on the screen
  bool hitTest(
    Offset position,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
    DrawingToolConfig config,
    DraggableEdgePoint draggableStartPoint,
    void Function({required bool isDragged}) setIsStartPointDragged, {
    DraggableEdgePoint? draggableEndPoint,
    void Function({required bool isDragged})? setIsEndPointDragged,
  });
}
