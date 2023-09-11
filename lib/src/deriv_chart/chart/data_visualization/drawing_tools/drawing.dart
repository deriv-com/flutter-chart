import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';

/// Base class to draw a particular drawing
abstract class Drawing {
  /// Will be called when the drawing is moved by the user gesture.
  ///
  /// Some drawing tools might required to handle some logic after the drawing
  /// is moved and we don't want this logic be done in the [onPaint] method
  /// because it runs more often and it might cause performance issues.
  ///
  /// The method has an empty implementation so only the [Drawing] subclasses
  /// that require this life-cycle method can override it.
  void onDrawingMoved(
    List<Tick> ticks,
    EdgePoint startPoint, {
    EdgePoint? endPoint,
  }) {}

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
    DraggableEdgePoint? draggableEndPoint,
  });

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
