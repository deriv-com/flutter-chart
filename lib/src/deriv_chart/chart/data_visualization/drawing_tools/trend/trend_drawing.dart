import 'dart:math';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/trend/trend_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
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
    required this.findClosestIndex,
    this.startingEdgePoint = const EdgePoint(),
    this.endingEdgePoint = const EdgePoint(),
  });

  /// Callback to get the epoch of first click on graph
  final int Function(int x, List<Tick>?)? findClosestIndex;

  /// Get epoch from x.
  int Function(double x)? epochFromX;

  /// Instance of enum including all possible drawing parts(marker,rectangle)
  final DrawingParts drawingPart;

  /// Marker radius.
  final double _markerRadius = 10;

  /// Keeps the latest position of the start and end point of drawing
  Point? _startPoint, _endPoint;

  /// Instance of MinMaxCalculator class that holds the minimum
  /// and maximum quote in the trend range w.r.t epoch
  MinMaxCalculator? _calculator;

  /// Store the  starting X Coordinate
  double startXCoord = 0;

  /// Store the  starting Y Coordinate
  double startYCoord = 0;

  /// Store the  ending X Coordinate
  double endXCoord = 0;

  /// The area impacted upon touch on  all lines within the
  /// trend drawing tool. .i.e outer rectangle , inner rectangle
  /// and center line.
  final double _touchTolerance = 5;

  ///  Starting point of drawing
  EdgePoint startingEdgePoint;

  /// Ending point of drawing
  EdgePoint endingEdgePoint;

  /// Function to check if the clicked position (Offset) is on
  /// boundary of the rectangle
  bool _isClickedOnRectangleBoundary(Rect rect, Offset position) {
    /// Width of the rectangle line
    const double lineWidth = 3;

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
      rect.width + _touchTolerance * 2 + 2,
      lineWidth + _touchTolerance * 2 + 2,
    );

    return topLineBounds.inflate(2).contains(position) ||
        leftLineBounds.inflate(2).contains(position) ||
        rightLineBounds.inflate(2).contains(position) ||
        bottomLineBounds.inflate(2).contains(position);
  }

  /// Store the complete rectangle between start,end epoch and
  /// minimum,maximum quote.
  Rect _mainRect = Rect.zero;

  /// Stores the middle rectangle for the trend ,
  Rect _middleRect = Rect.zero;

  /// Stores the center of the area for the markers
  double _rectCenter = 0;

  /// Stores a flag if the rectangle sides are swapped .i.e the left
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
    Point Function(
      EdgePoint edgePoint,
      DraggableEdgePoint draggableEdgePoint,
    ) updatePositionCallback,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableEndPoint,
  }) {
    final DrawingPaintStyle paint = DrawingPaintStyle();
    final List<Tick>? series = drawingData.series;
    //  Maximum epoch of the drawing
    final int minimumEpoch =
        startXCoord == 0 ? startingEdgePoint.epoch : epochFromX!(startXCoord);

    //  Minimum epoch of the drawing
    final int maximumEpoch =
        endXCoord == 0 ? endingEdgePoint.epoch : epochFromX!(endXCoord);

    // Range of epoch between minimum and maximum epoch
    if (maximumEpoch != 0 && minimumEpoch != 0) {
      int minimumEpochIndex = findClosestIndex!(minimumEpoch, series);
      int maximumEpochIndex = findClosestIndex!(maximumEpoch, series);

      if (minimumEpochIndex > maximumEpochIndex) {
        final int tempEpochIndex = minimumEpochIndex;
        minimumEpochIndex = maximumEpochIndex;
        maximumEpochIndex = tempEpochIndex;
      }

      final List<Tick>? epochRange =
          series!.sublist(minimumEpochIndex, maximumEpochIndex);

      double minValueOf(Tick t) => t.quote;
      double maxValueOf(Tick t) => t.quote;

      //  Min max calculator getting the minimum and maximum
      // epoch from epochrange
      _calculator = MinMaxCalculator(minValueOf, maxValueOf)
        ..calculate(epochRange!);

      // Setting the center of the rectangle
      _rectCenter = quoteToY(_calculator!.min) +
          ((quoteToY(_calculator!.max) - quoteToY(_calculator!.min)) / 2);
    }

    final TrendDrawingToolConfig config =
        drawingData.config as TrendDrawingToolConfig;

    final LineStyle lineStyle = config.lineStyle;
    final LineStyle fillStyle = config.fillStyle;
    final DrawingPatterns pattern = config.pattern;

    if (_calculator != null) {
      _startPoint = updatePositionCallback(
          EdgePoint(
              epoch: startingEdgePoint.epoch,
              quote:
                  _calculator!.min + (_calculator!.max - _calculator!.min) / 2),
          draggableStartPoint);

      _endPoint = updatePositionCallback(
          EdgePoint(
              epoch: endingEdgePoint.epoch,
              quote:
                  _calculator!.min + (_calculator!.max - _calculator!.min) / 2),
          draggableEndPoint!);

      startXCoord = _startPoint!.x;
      startYCoord = _startPoint!.y;

      endXCoord = _endPoint!.x;
    }

    // If the rectangle vertical side are swapped
    // .i.e dragging left side to the right of the right side
    if (endXCoord < startXCoord && endingEdgePoint.epoch != 0) {
      final double _tempCoord = endXCoord;
      endXCoord = startXCoord;
      startXCoord = _tempCoord;
      _isRectangleSwapped = true;
    } else {
      _isRectangleSwapped = false;
    }

    /// When both points are dragged to same point
    if (_calculator != null && quoteToY(_calculator!.max).isNaN) {
      return;
    }

    if (drawingPart == DrawingParts.marker) {
      if (endingEdgePoint.epoch == 0) {
        _startPoint = updatePositionCallback(
            EdgePoint(
                epoch: startingEdgePoint.epoch, quote: startingEdgePoint.quote),
            draggableStartPoint);

        startXCoord = _startPoint!.x;
        startYCoord = _startPoint!.y;

        canvas.drawCircle(
          Offset(startXCoord, startYCoord),
          _markerRadius,
          drawingData.isSelected
              ? paint.glowyCirclePaintStyle(lineStyle.color)
              : paint.transparentCirclePaintStyle(),
        );
      } else {
        canvas
          ..drawCircle(
            Offset(startXCoord, _rectCenter),
            _markerRadius,
            drawingData.isSelected
                ? paint.glowyCirclePaintStyle(lineStyle.color)
                : paint.transparentCirclePaintStyle(),
          )
          ..drawCircle(
            Offset(endXCoord, _rectCenter),
            _markerRadius,
            drawingData.isSelected
                ? paint.glowyCirclePaintStyle(lineStyle.color)
                : paint.transparentCirclePaintStyle(),
          );
      }
    }

    if (drawingPart == DrawingParts.rectangle) {
      /// Store the distance between minimum and maximum quote of the drawing
      final double _distance =
          (quoteToY(_calculator!.min) - quoteToY(_calculator!.max)).abs();

      if (pattern == DrawingPatterns.solid) {
        _middleRect = Rect.fromLTRB(
          startXCoord,
          quoteToY(_calculator!.max) + _distance / 3,
          endXCoord,
          quoteToY(_calculator!.max) + (_distance - _distance / 3),
        );

        _mainRect = Rect.fromLTRB(
          startXCoord,
          quoteToY(_calculator!.max),
          endXCoord,
          quoteToY(_calculator!.min),
        );

        canvas
          ..drawRect(
            _mainRect,
            drawingData.isSelected
                ? paint.glowyLinePaintStyle(
                    fillStyle.color.withOpacity(0.2), lineStyle.thickness)
                : paint.fillPaintStyle(
                    fillStyle.color.withOpacity(0.2), lineStyle.thickness),
          )
          ..drawRect(
            _mainRect,
            paint.strokeStyle(lineStyle.color, lineStyle.thickness),
          )
          ..drawRect(
            _middleRect,
            drawingData.isSelected
                ? paint.glowyLinePaintStyle(
                    fillStyle.color.withOpacity(0.2), lineStyle.thickness)
                : paint.fillPaintStyle(
                    fillStyle.color.withOpacity(0.2), lineStyle.thickness),
          )
          ..drawRect(
            _middleRect,
            paint.strokeStyle(lineStyle.color, lineStyle.thickness),
          );
      }
    }

    if (drawingPart == DrawingParts.line) {
      if (pattern == DrawingPatterns.solid) {
        canvas.drawLine(
          Offset(startXCoord, _rectCenter),
          Offset(endXCoord, _rectCenter),
          paint.glowyCirclePaintStyle(lineStyle.color),
        );
      }
    }
  }

  /// Calculation for detemining whether a user's touch or click intersects
  /// with any of the painted areas on the screen,
  /// the drawing is selected on clicking on any boundary(line) of the drawing
  @override
  bool hitTest(
    Offset position,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
    DrawingToolConfig config,
    DraggableEdgePoint draggableStartPoint,
    void Function({required bool isDragged}) setIsStartPointDragged, {
    DraggableEdgePoint? draggableEndPoint,
    void Function({required bool isDragged})? setIsEndPointDragged,
  }) {
    // Calculate the difference between the start Point and the tap point.
    final double startDx = position.dx - startXCoord;
    final double startDy = position.dy - _rectCenter;

    // Calculate the difference between the end Point and the tap point.
    final double endDx = position.dx - endXCoord;
    final double endDy = position.dy - _rectCenter;

    // Getting the distance of end point
    double endPointDistance = sqrt(endDx * endDx + endDy * endDy);

    // Getting the distance of start point
    double startPointDistance = sqrt(startDx * startDx + startDy * startDy);

    if (_isRectangleSwapped) {
      final double tempDistance = startPointDistance;
      startPointDistance = endPointDistance;
      endPointDistance = tempDistance;
    }

    if (startPointDistance <= _markerRadius) {
      setIsStartPointDragged(isDragged: true);
    }

    if (endPointDistance <= _markerRadius) {
      setIsEndPointDragged!(isDragged: true);
    }

    // For clicking the center line

    final double lineArea = (0.5 *
            (startXCoord * _rectCenter +
                endXCoord * position.dy +
                position.dx * _rectCenter -
                endXCoord * _rectCenter -
                position.dx * _rectCenter -
                startXCoord * position.dy))
        .abs();

    final double baseArea = endXCoord - startXCoord;
    final double lineHeight = 2 * lineArea / baseArea;

    if (endingEdgePoint.epoch != 0) {
      return _isClickedOnRectangleBoundary(_mainRect, position) ||
          _isClickedOnRectangleBoundary(_middleRect, position) ||
          startPointDistance <= _markerRadius ||
          endPointDistance <= _markerRadius ||
          lineHeight <= _touchTolerance;
    }
    return false;
  }
}
