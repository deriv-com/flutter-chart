import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/vector.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
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

  /// Vector of the line
  Vector getLineVector(
    double startXCoord,
    double startQuoteToY,
    double endXCoord,
    double endQuoteToY, {
    bool exceedStart = false,
    bool exceedEnd = false,
  }) {
    Vector vec = Vector(
      x0: startXCoord,
      y0: startQuoteToY,
      x1: endXCoord,
      y1: endQuoteToY,
    );

    late double earlier, later;
    if (exceedEnd && !exceedStart) {
      earlier = vec.x0;
      if (vec.x0 > vec.x1) {
        later = vec.x1 - 100000;
      } else {
        later = vec.x1 + 100000;
      }
    }
    if (exceedStart && !exceedEnd) {
      later = vec.x1;

      if (vec.x0 > vec.x1) {
        earlier = vec.x0 + 100000;
      } else {
        earlier = vec.x0 - 100000;
      }
    }

    if (exceedStart && exceedEnd) {
      if (vec.x0 > vec.x1) {
        vec = Vector(
          x0: endXCoord,
          y0: endQuoteToY,
          x1: startXCoord,
          y1: startQuoteToY,
        );
      }

      earlier = vec.x0 - 100000;
      later = vec.x1 + 100000;
    }

    if (!exceedEnd && !exceedStart) {
      if (vec.x0 > vec.x1) {
        vec = Vector(
          x0: endXCoord,
          y0: endQuoteToY,
          x1: startXCoord,
          y1: startQuoteToY,
        );
      }
      earlier = vec.x0;
      later = vec.x1;
    }

    final double startY = getYIntersection(vec, earlier) ?? 0,
        endingY = getYIntersection(vec, later) ?? 0,
        startX = earlier,
        endingX = later;

    return Vector(
      x0: startX,
      y0: startY,
      x1: endingX,
      y1: endingY,
    );
  }

  /// Returns the Triangle path
  Path getTrianglePath(
    Vector startVector,
    Vector endVector,
  ) =>
      Path()
        ..moveTo(startVector.x0, startVector.y0)
        ..lineTo(startVector.x1, startVector.y1)
        ..lineTo(endVector.x1, endVector.y1)
        ..close();
}
