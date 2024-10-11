import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/channel/channel_drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/fibfan/fibfan_drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/horizontal/horizontal_drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/line/line_drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/ray/ray_line_drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/rectangle/rectangle_drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/trend/trend_drawing.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

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
      case HorizontalDrawing.nameKey:
        return HorizontalDrawing.fromJson(json);
      case LineDrawing.nameKey:
        return LineDrawing.fromJson(json);
      case RayLineDrawing.nameKey:
        return RayLineDrawing.fromJson(json);
      case RectangleDrawing.nameKey:
        return RectangleDrawing.fromJson(json);
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

  /// Will be called when the drawing is moved by the user gesture.
  ///
  /// Some drawing tools might required to handle some logic after the drawing
  /// is moved and we don't want this logic be done in the [onPaint] method
  /// because it runs more often and it might cause performance issues.
  ///
  /// The method has an empty implementation so only the [Drawing] subclasses
  /// that require this life-cycle method can override it.
  ///
  // TODO(Bahar-Deriv): Decide if we need to pass the [draggableMiddlePoint]
  /// and change the method name
  void onDrawingMoved(
    int Function(double x) epochFromX,
    List<Tick> ticks,
    EdgePoint startPoint, {
    EdgePoint? middlePoint,
    EdgePoint? endPoint,
  }) {}

  /// Paints Label
  void onLabelPaint(
    Canvas canvas,
    Size size,
    ChartTheme theme,
    ChartConfig chartConfig,
    int Function(double x) epochFromX,
    double Function(double) quoteFromY,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
    DrawingToolConfig config,
    DrawingData drawingData,
    DataSeries<Tick> series,
  ) {}

  /// Is called before repaint the drawing to check if it needs to be
  /// repainted.
  ///
  /// Returns true if the drawing needs to be repainted.
  ///
  /// Since the [Drawing] class instances are mutable and live across the
  /// painting frames, there is no previous instance of it provided in this
  /// method to compare with and decide for repainting.
  ///
  /// Repainting condition for drawing usually is based on whether they are
  /// in the chart visible area or not.
  bool needsRepaint(
    int leftEpoch,
    int rightEpoch,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableMiddlePoint,
    DraggableEdgePoint? draggableEndPoint,
  });

  /// Paint
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
  });

  /// Calculates whether a user's touch or click intersects
  /// with any of the painted areas on the screen
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
  });
}
