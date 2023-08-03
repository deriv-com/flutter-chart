import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/vector.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';

/// Base class to draw a particular drawing
abstract class Drawing {
  /// Paint
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
    List<Tick>? series,
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
