import 'dart:math';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/trend/trend_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/functions/min_max_calculator.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';

/// Line drawing tool. A line is a vector defined by two points that is
/// infinite in both directions.
class TrendDrawing extends Drawing {
  /// Initializes
  TrendDrawing(
      {required this.drawingPart,
      required this.series,
      required this.epochFromX,
      this.startEpoch = 0,
      this.startYCoord = 0,
      this.endEpoch = 0,
      this.endYCoord = 0,
      this.maxValList});

  final DataSeries<Tick> series;

  /// Get epoch from x.
  int Function(double x)? epochFromX;

  /// Part of a drawing: 'marker' or 'line'
  final DrawingParts drawingPart;

  ///
  final List<Tick>? maxValList;

  /// Starting epoch.
  final int startEpoch;

  /// Starting Y coordinates.
  final double startYCoord;

  /// Ending epoch.
  final int endEpoch;

  /// Ending Y coordinates.
  final double endYCoord;

  /// Marker radius.
  final double _markerRadius = 10;

  /// Keeps the latest position of the start and end point of drawing
  Point? _startPoint, _endPoint;

  MinMaxCalculator? calculator;

  double distance = 0;

  double startXCoord = 0;
  double startQuoteToY = 0;

  double endXCoord = 0;
  double endQuoteToY = 0;

  Rect wholeRect = Rect.zero;

  double yAxis = 0;

  /// Paint the line
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
    final TrendDrawingToolConfig config =
        drawingData.config as TrendDrawingToolConfig;

    final LineStyle lineStyle = config.lineStyle;
    final LineStyle fillStyle = config.fillStyle;
    final String pattern = config.pattern;

    if (drawingPart == DrawingParts.marker) {
      _startPoint = draggableStartPoint.updatePosition(
          startEpoch, startYCoord, epochToX, quoteToY);
      _endPoint = draggableEndPoint!
          .updatePosition(endEpoch, endYCoord, epochToX, quoteToY);

      startXCoord = _startPoint!.x;
      startQuoteToY = _startPoint!.y;

      endXCoord = _endPoint!.x;
      endQuoteToY = _endPoint!.y;

      if (startEpoch != 0 && startQuoteToY != 0) {
        /// Draw second point
        canvas.drawCircle(
            Offset(startXCoord, startQuoteToY),
            _markerRadius,
            drawingData.isSelected
                ? paint.glowyCirclePaintStyle(lineStyle.color)
                : paint.transparentCirclePaintStyle());
      }
    }

    if (drawingPart == DrawingParts.rectangle) {
      double minValueOf(Tick t) => t.quote;
      double maxValueOf(Tick t) => t.quote;
      final num minVal =
          startXCoord == 0 ? startEpoch : epochFromX!(startXCoord);

      final num maxsVal = endXCoord == 0 ? endEpoch : epochFromX!(endXCoord);

      final List<Tick>? maxVal = series.entries
          ?.where((Tick i) => i.epoch >= minVal && i.epoch <= maxsVal)
          .toList();

      calculator = MinMaxCalculator(minValueOf, maxValueOf)..calculate(maxVal!);

      distance = (quoteToY(calculator!.min) - quoteToY(calculator!.max)).abs();

      _startPoint = draggableStartPoint.updatePosition(
          startEpoch,
          calculator!.min + (calculator!.max - calculator!.min) / 2,
          epochToX,
          quoteToY);

      _endPoint = draggableEndPoint!.updatePosition(
          endEpoch,
          calculator!.min + (calculator!.max - calculator!.min) / 2,
          epochToX,
          quoteToY);

      startXCoord = _startPoint!.x;
      startQuoteToY = _startPoint!.y;

      endXCoord = _endPoint!.x;
      endQuoteToY = _endPoint!.y;
      if (endXCoord < startXCoord) {
        final double temp = endXCoord;
        endXCoord = startXCoord;
        startXCoord = temp;
      }

      if (pattern == 'solid') {
        final Rect topRect = Rect.fromLTRB(
            startXCoord,
            quoteToY(calculator!.max),
            endXCoord,
            quoteToY(calculator!.max) + distance / 3);

        final Rect centerRect = Rect.fromLTRB(
            startXCoord,
            quoteToY(calculator!.max) + distance / 3 + 2,
            endXCoord,
            quoteToY(calculator!.max) + (distance - distance / 3));

        final Rect bottomRect = Rect.fromLTRB(
            startXCoord,
            quoteToY(calculator!.max) + (distance - distance / 3) + 2,
            endXCoord,
            quoteToY(calculator!.min));

        yAxis = quoteToY(calculator!.min) +
            ((quoteToY(calculator!.max) - quoteToY(calculator!.min)) / 2);

        wholeRect = Rect.fromLTRB(startXCoord, quoteToY(calculator!.max),
            endXCoord, quoteToY(calculator!.min));

        canvas
          ..drawRect(
              topRect,
              drawingData.isSelected
                  ? paint.glowyLinePaintStyle(
                      lineStyle.color, lineStyle.thickness)
                  : Paint()
                ..color = fillStyle.color.withOpacity(0.3)
                ..style = PaintingStyle.fill
                ..strokeWidth = lineStyle.thickness)
          ..drawRect(
              centerRect,
              drawingData.isSelected
                  ? paint.glowyLinePaintStyle(
                      lineStyle.color, lineStyle.thickness)
                  : Paint()
                ..color = fillStyle.color.withOpacity(0.3)
                ..style = PaintingStyle.fill
                ..strokeWidth = lineStyle.thickness)
          ..drawRect(
              bottomRect,
              drawingData.isSelected
                  ? paint.glowyLinePaintStyle(
                      lineStyle.color, lineStyle.thickness)
                  : Paint()
                ..color = fillStyle.color.withOpacity(0.3)
                ..style = PaintingStyle.fill
                ..strokeWidth = lineStyle.thickness)
          ..drawCircle(
              Offset(endXCoord, yAxis),
              _markerRadius,
              drawingData.isSelected
                  ? paint.glowyCirclePaintStyle(lineStyle.color)
                  : paint.transparentCirclePaintStyle())
          ..drawCircle(
              Offset(startXCoord, yAxis),
              _markerRadius,
              drawingData.isSelected
                  ? paint.glowyCirclePaintStyle(lineStyle.color)
                  : paint.transparentCirclePaintStyle());
      }
    }
  }

  @override
  bool hitTest(
    Offset position,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
    DrawingToolConfig config,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableEndPoint,
  }) {
    // yAxis;

    // Calculate the difference between the start Point and the tap point.
    final double startDx = position.dx - startXCoord;
    final double startDy = position.dy - yAxis;

    // Calculate the difference between the end Point and the tap point.
    final double endDx = position.dx - endXCoord;
    final double endDy = position.dy - yAxis;

    // getting the distance of end point
    final double endPointDistance = sqrt(endDx * endDx + endDy * endDy);

    // getting the distance of start point
    final double startPointDistance =
        sqrt(startDx * startDx + startDy * startDy);

    /// Check if start point clicked
    if (_startPoint!.isClicked(position, _markerRadius)) {
      draggableStartPoint.isDragged = true;
    }

    /// Check if end point clicked
    if (_endPoint!.isClicked(position, _markerRadius)) {
      draggableEndPoint!.isDragged = true;
    }
    // If the distance (endpoint and startpoint) is less or equal to the
    //marker radius, it means the tap was inside the circle

    if (endPointDistance <= _markerRadius ||
        startPointDistance <= _markerRadius) {
      print('inside circle clicked !!1');
      return true;
    }

    if (wholeRect.contains(position) && endEpoch != 0) {
      return true;
    }

    return false;
  }
}
