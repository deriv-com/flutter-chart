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

/// Trend drawing tool.
class TrendDrawing extends Drawing {
  /// Initializes
  TrendDrawing({
    required this.drawingPart,
    required this.epochFromX,
    this.startingEpoch = 0,
    this.startingQuote = 0,
    this.endingEpoch = 0,
    this.endingQuote = 0,
  });

  /// Get epoch from x.
  int Function(double x)? epochFromX;

  /// instance of enum including all possible drawing parts(marker,rectangle)
  final DrawingParts drawingPart;

  /// Starting epoch.
  final int startingEpoch;

  /// Starting quote.
  final double startingQuote;

  /// Ending epoch.
  final int endingEpoch;

  /// Ending Y quote.
  final double endingQuote;

  /// Marker radius.
  final double _markerRadius = 10;

  /// Keeps the latest position of the start and end point of drawing
  Point? _startPoint, _endPoint;

  /// instance of MinMaxCalculator class for getting the minimum and maximum
  ///  quote w.r.t epoch
  MinMaxCalculator? _calculator;

  /// store the  starting X Coordinate
  double startXCoord = 0;

  /// store the  starting Y Coordinate
  double startYCoord = 0;

  /// store the  ending X Coordinate
  double endXCoord = 0;

  /// the area affected on touch
  final double _touchTolerance = 5;

  /// function to check if the clicked position (Offset) is on
  /// boundary of the rectangle
  bool _isClickedOnRectangleBoundary(Rect rect, Offset position) {
    /// width of the rectangle line
    const double lineWidth = 2;

    final Rect topLineBounds = Rect.fromLTWH(
      rect.left - _touchTolerance,
      rect.top - _touchTolerance,
      rect.width + _touchTolerance * 2,
      lineWidth + _touchTolerance * 2,
    );

    final Rect leftLineBounds = Rect.fromLTWH(
      rect.left - _touchTolerance,
      rect.top - _touchTolerance,
      lineWidth + _touchTolerance * 2,
      rect.height + _touchTolerance * 2,
    );

    final Rect rightLineBounds = Rect.fromLTWH(
      rect.right - lineWidth - _touchTolerance * 2,
      rect.top - _touchTolerance,
      lineWidth + _touchTolerance * 2,
      rect.height + _touchTolerance * 2,
    );

    final Rect bottomLineBounds = Rect.fromLTWH(
      rect.left - _touchTolerance,
      rect.bottom - lineWidth - _touchTolerance * 2,
      rect.width + _touchTolerance * 2,
      lineWidth + _touchTolerance * 2,
    );

    return topLineBounds.contains(position) ||
        leftLineBounds.contains(position) ||
        rightLineBounds.contains(position) ||
        bottomLineBounds.contains(position);
  }

  /// store the complete Rectangule between start,end epoch and
  /// minimum,maximum quote.
  Rect _mainRect = Rect.zero;

  /// stores the middle Rectangle for the trend ,
  Rect _middleRect = Rect.zero;

  /// stores the center of the area for the markers
  double _rectCenter = 0;

  /// stores a flag if the rectangle sides are swapped .i.e the left
  /// side is dragged to the right of the right side
  bool _isRectangleSwapped = false;

  /// Paint the trend drawing tools
  @override
  void onPaint(
      Canvas canvas,
      Size size,
      ChartTheme theme,
      double Function(int x) epochToX,
      double Function(double y) quoteToY,
      DrawingData drawingData,
      DraggableEdgePoint draggableStartPoint,
      {DraggableEdgePoint? draggableEndPoint,
      List<Tick>? series}) {
    final DrawingPaintStyle paint = DrawingPaintStyle();

    final num minimumEpoch =
        startXCoord == 0 ? startingEpoch : epochFromX!(startXCoord);

    ///  minimum epoch of the drawing
    final num maximumEpoch =
        endXCoord == 0 ? endingEpoch : epochFromX!(endXCoord);

    /// range of epoch between minimum and maximum epoch
    if (maximumEpoch != 0 && minimumEpoch != 0) {
      final List<Tick>? epochRange = series
          ?.where(
              (Tick i) => i.epoch >= minimumEpoch && i.epoch <= maximumEpoch)
          .toList();

      double minValueOf(Tick t) => t.quote;
      double maxValueOf(Tick t) => t.quote;

      ///  min max calculator getting the minimum and maximum
      /// epoch from epochrange
      _calculator = MinMaxCalculator(minValueOf, maxValueOf)
        ..calculate(epochRange!);

      /// setting the center of the rectangle
      _rectCenter = quoteToY(_calculator!.min) +
          ((quoteToY(_calculator!.max) - quoteToY(_calculator!.min)) / 2);
    }

    final TrendDrawingToolConfig config =
        drawingData.config as TrendDrawingToolConfig;

    final LineStyle lineStyle = config.lineStyle;
    final LineStyle fillStyle = config.fillStyle;
    final String pattern = config.pattern;

    if (_calculator != null) {
      _startPoint = draggableStartPoint.updatePosition(
          startingEpoch,
          _calculator!.min + (_calculator!.max - _calculator!.min) / 2,
          epochToX,
          quoteToY);

      _endPoint = draggableEndPoint!.updatePosition(
          endingEpoch,
          _calculator!.min + (_calculator!.max - _calculator!.min) / 2,
          epochToX,
          quoteToY);

      startXCoord = _startPoint!.x;
      startYCoord = _startPoint!.y;

      endXCoord = _endPoint!.x;
    }

    /// if the rectangle vertical side are swapped
    /// .i.e dragging left side to the right of the right side
    if (endXCoord < startXCoord && endingEpoch != 0) {
      final double _tempCoord = endXCoord;
      endXCoord = startXCoord;
      startXCoord = _tempCoord;
      _isRectangleSwapped = true;
    } else {
      _isRectangleSwapped = false;
    }

    /// when both points are dragged to same point
    if (_calculator != null && quoteToY(_calculator!.max).isNaN) {
      return;
    }

    if (drawingPart == DrawingParts.marker) {
      if (endingEpoch == 0) {
        final List<Tick>? chartValue =
            series?.where((Tick i) => i.epoch >= startingEpoch).toList();

        final Tick? pointVal = chartValue?[0];

        _startPoint = draggableStartPoint.updatePosition(
            pointVal!.epoch, pointVal.quote, epochToX, quoteToY);

        startXCoord = _startPoint!.x;
        startYCoord = _startPoint!.y;

        canvas.drawCircle(
            Offset(startXCoord, startYCoord),
            _markerRadius,
            drawingData.isSelected
                ? paint.glowyCirclePaintStyle(lineStyle.color)
                : paint.transparentCirclePaintStyle());
      } else {
        canvas
          ..drawCircle(
              Offset(startXCoord, _rectCenter),
              _markerRadius,
              drawingData.isSelected
                  ? paint.glowyCirclePaintStyle(lineStyle.color)
                  : paint.transparentCirclePaintStyle())
          ..drawCircle(
              Offset(endXCoord, _rectCenter),
              _markerRadius,
              drawingData.isSelected
                  ? paint.glowyCirclePaintStyle(lineStyle.color)
                  : paint.transparentCirclePaintStyle());
      }
    }

    if (drawingPart == DrawingParts.rectangle) {
      /// store the distance between minimum and maximum quote of the drawing
      final double _distance =
          (quoteToY(_calculator!.min) - quoteToY(_calculator!.max)).abs();

      if (pattern == 'solid') {
        _middleRect = Rect.fromLTRB(
            startXCoord,
            quoteToY(_calculator!.max) + _distance / 3,
            endXCoord,
            quoteToY(_calculator!.max) + (_distance - _distance / 3));

        _mainRect = Rect.fromLTRB(startXCoord, quoteToY(_calculator!.max),
            endXCoord, quoteToY(_calculator!.min));

        canvas
          ..drawRect(
              _mainRect,
              drawingData.isSelected
                  ? paint.glowyLinePaintStyle(
                      fillStyle.color.withOpacity(0.2), lineStyle.thickness)
                  : paint.fillPaintStyle(
                      fillStyle.color.withOpacity(0.2), lineStyle.thickness))
          ..drawRect(_mainRect,
              paint.strokeStyle(lineStyle.color, lineStyle.thickness))
          ..drawRect(
              _middleRect,
              drawingData.isSelected
                  ? paint.glowyLinePaintStyle(
                      fillStyle.color.withOpacity(0.2), lineStyle.thickness)
                  : paint.fillPaintStyle(
                      fillStyle.color.withOpacity(0.2), lineStyle.thickness))
          ..drawRect(_middleRect,
              paint.strokeStyle(lineStyle.color, lineStyle.thickness));
      }
    }

    if (drawingPart == DrawingParts.line) {
      canvas.drawLine(
          Offset(startXCoord, _rectCenter),
          Offset(endXCoord, _rectCenter),
          paint.glowyCirclePaintStyle(lineStyle.color));
    }
  }

  // Calculation for detemining whether a user's touch or click intersects
  /// with any of the painted areas on the screen,
  /// the drawing is selected on clicking on any boundary(line) of the drawing
  @override
  bool hitTest(
    Offset position,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
    DrawingToolConfig config,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableEndPoint,
  }) {
    // Calculate the difference between the start Point and the tap point.
    final double startDx = position.dx - startXCoord;
    final double startDy = position.dy - _rectCenter;

    // Calculate the difference between the end Point and the tap point.
    final double endDx = position.dx - endXCoord;
    final double endDy = position.dy - _rectCenter;

    // getting the distance of end point
    double endPointDistance = sqrt(endDx * endDx + endDy * endDy);

    // getting the distance of start point
    double startPointDistance = sqrt(startDx * startDx + startDy * startDy);

    if (_isRectangleSwapped) {
      final double tempDistance = startPointDistance;
      startPointDistance = endPointDistance;
      endPointDistance = tempDistance;
    }

    if (startPointDistance <= _markerRadius) {
      draggableStartPoint.isDragged = true;
    }

    if (endPointDistance <= _markerRadius) {
      draggableEndPoint!.isDragged = true;
    }

    // for clicking the center line
    final double lineArea = (0.5 *
            (startXCoord * _rectCenter +
                endXCoord * position.dy +
                position.dx * _rectCenter -
                endXCoord * _rectCenter -
                position.dx * _rectCenter -
                startXCoord * position.dy))
        .abs();

    final double base = endXCoord - startXCoord;
    final double lineHeight = 2 * lineArea / base;

    if (endingEpoch != 0) {
      return _isClickedOnRectangleBoundary(_mainRect, position) ||
          _isClickedOnRectangleBoundary(_middleRect, position) ||
          startPointDistance <= _markerRadius ||
          endPointDistance <= _markerRadius ||
          lineHeight <= _touchTolerance;
    }

    return false;
  }
}
