import 'dart:math';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/trend/trend_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/find.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_pattern.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/extensions/extensions.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/functions/min_max_calculator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trend_drawing.g.dart';

/// Trend drawing tool.
@JsonSerializable()
class TrendDrawing extends Drawing {
  /// Initializes
  TrendDrawing({
    required this.drawingPart,
    this.startEdgePoint = const EdgePoint(),
    this.endEdgePoint = const EdgePoint(),
  });

  /// Initializes from JSON.
  factory TrendDrawing.fromJson(Map<String, dynamic> json) =>
      _$TrendDrawingFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TrendDrawingToJson(this)
    ..putIfAbsent(Drawing.classNameKey, () => nameKey);

  /// Key of drawing tool name property in JSON.
  static const String nameKey = 'TrendDrawing';

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

  ///  Starting point of drawing
  EdgePoint startEdgePoint;

  /// Ending point of drawing
  EdgePoint endEdgePoint;

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

  /// The area impacted upon touch on  all lines within the
  /// trend drawing tool. .i.e outer rectangle , inner rectangle
  /// and center line.
  final double _touchTolerance = 5;

  /// When two point overlap with each other
  bool _isPointOverlapped = false;

  /// It holds the last valid of maximum tick from calculator
  double _maxYCoord = 0;

  /// Setting the minmax calculator between the range of
  /// start and end epoch
  MinMaxCalculator? _setCalculator(
    int minimumEpoch,
    int maximumEpoch,
    List<Tick>? series,
  ) {
    int minimumEpochIndex = findClosestIndexBinarySearch(minimumEpoch, series);
    int maximumEpochIndex = findClosestIndexBinarySearch(maximumEpoch, series);

    if (minimumEpochIndex > maximumEpochIndex) {
      final int tempEpochIndex = minimumEpochIndex;
      minimumEpochIndex = maximumEpochIndex;
      maximumEpochIndex = tempEpochIndex;
    }

    final List<Tick>? epochRange =
        series!.sublist(minimumEpochIndex, maximumEpochIndex);

    double minValueOf(Tick t) => t.quote;
    double maxValueOf(Tick t) => t.quote;

    return MinMaxCalculator(minValueOf, maxValueOf)..calculate(epochRange!);
  }

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

  // TODO(Bahar-deriv): implement onDrawingMoved here later

  @override
  bool needsRepaint(
    int leftEpoch,
    int rightEpoch,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableMiddlePoint,
    DraggableEdgePoint? draggableEndPoint,
  }) =>
      draggableStartPoint.isInViewPortRange(leftEpoch, rightEpoch) ||
      (draggableEndPoint?.isInViewPortRange(leftEpoch, rightEpoch) ?? true);

  /// Paint the trend drawing tools
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
    config as TrendDrawingToolConfig;

    final DrawingPaintStyle paint = DrawingPaintStyle();
    final List<EdgePoint> edgePoints = config.edgePoints;

    //  Maximum epoch of the drawing
    final int minimumEpoch = draggableStartPoint.getEdgePoint().epoch != 0
        ? draggableStartPoint.getEdgePoint().epoch
        : edgePoints.first.epoch;

    //  Minimum epoch of the drawing
    final int maximumEpoch = draggableEndPoint != null &&
            draggableEndPoint.getEdgePoint().epoch != 0
        ? draggableEndPoint.getEdgePoint().epoch
        : (edgePoints.length > 1 ? edgePoints.last.epoch : endEdgePoint.epoch);

    if (maximumEpoch != 0 && minimumEpoch != 0) {
      // setting calculator
      _calculator = _setCalculator(minimumEpoch, maximumEpoch, series.entries);

      if (_calculator != null) {
        // center of rectangle
        _rectCenter = quoteToY(_calculator!.min) +
            ((quoteToY(_calculator!.max) - quoteToY(_calculator!.min)) / 2);
      }
    }

    final LineStyle lineStyle = config.lineStyle;
    final LineStyle fillStyle = config.fillStyle;
    final DrawingPatterns pattern = config.pattern;

    if (_calculator != null) {
      if (maximumEpoch != 0 && minimumEpoch != 0) {
        // center of rectangle
        _rectCenter = quoteToY(_calculator!.min) +
            ((quoteToY(_calculator!.max) - quoteToY(_calculator!.min)) / 2);
      }

      final double minValue = _calculator!.min;
      final double maxValue = _calculator!.max;
      final bool isMidpointNaN = minValue.isNaN || maxValue.isNaN;

      _startPoint = updatePositionCallback(
          EdgePoint(
              epoch: edgePoints.first.epoch,
              quote: isMidpointNaN
                  ? endEdgePoint.quote
                  : minValue + (maxValue - minValue) / 2),
          draggableStartPoint);

      _endPoint = updatePositionCallback(
          EdgePoint(
            epoch: (edgePoints.length > 1
                ? edgePoints.last.epoch
                : endEdgePoint.epoch),
            quote: isMidpointNaN
                ? endEdgePoint.quote
                : (minValue + (maxValue - minValue) / 2),
          ),
          draggableEndPoint!);

      startXCoord = _startPoint!.x;
      startYCoord = _startPoint!.y;

      endXCoord = _endPoint!.x;
    }

    // If the rectangle vertical side are swapped
    // .i.e dragging left side to the right of the right side
    if (endXCoord < startXCoord && endEdgePoint.epoch != 0) {
      final double _tempCoord = endXCoord;
      endXCoord = startXCoord;
      startXCoord = _tempCoord;
      _isRectangleSwapped = true;
    } else {
      _isRectangleSwapped = false;
    }

    /// When both points are dragged to same point or difference between points
    ///  is very less
    _isPointOverlapped =
        _calculator != null && quoteToY(_calculator!.max).isNaN ||
            (startXCoord - endXCoord).abs() <= 10;

    if (_calculator != null) {
      if (!quoteToY(_calculator!.max).isNaN && edgePoints.length != 1) {
        _maxYCoord = quoteToY(_calculator!.max);
      }

      if (_isPointOverlapped && endEdgePoint.epoch != 0) {
        canvas.drawCircle(
          Offset(startXCoord, _maxYCoord),
          _markerRadius,
          paint.glowyCirclePaintStyle(lineStyle.color),
        );
        return;
      }
    }

    if (drawingPart == DrawingParts.marker) {
      if (edgePoints.length == 1) {
        _startPoint = updatePositionCallback(
            EdgePoint(
                epoch: edgePoints.first.epoch, quote: edgePoints.last.quote),
            draggableStartPoint);

        startXCoord = _startPoint!.x;
        startYCoord = _startPoint!.y;

        canvas.drawCircle(
          Offset(startXCoord, startYCoord),
          _markerRadius,
          drawingData.shouldHighlight
              ? paint.glowyCirclePaintStyle(lineStyle.color)
              : paint.transparentCirclePaintStyle(),
        );
      } else {
        canvas
          ..drawCircle(
            Offset(startXCoord, _rectCenter),
            _markerRadius,
            drawingData.shouldHighlight
                ? paint.glowyCirclePaintStyle(lineStyle.color)
                : paint.transparentCirclePaintStyle(),
          )
          ..drawCircle(
            Offset(endXCoord, _rectCenter),
            _markerRadius,
            drawingData.shouldHighlight
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
            drawingData.shouldHighlight
                ? paint.glowyLinePaintStyle(
                    fillStyle.color.withOpacity(0.2), lineStyle.thickness)
                : paint.fillPaintStyle(fillStyle.color, lineStyle.thickness),
          )
          ..drawRect(
            _mainRect,
            paint.strokeStyle(lineStyle.color, lineStyle.thickness),
          )
          ..drawRect(
            _middleRect,
            drawingData.shouldHighlight
                ? paint.glowyLinePaintStyle(
                    fillStyle.color.withOpacity(0.2), lineStyle.thickness)
                : paint.fillPaintStyle(fillStyle.color, lineStyle.thickness),
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
    void Function({required bool isOverPoint}) setIsOverStartPoint, {
    DraggableEdgePoint? draggableMiddlePoint,
    DraggableEdgePoint? draggableEndPoint,
    void Function({required bool isOverPoint})? setIsOverMiddlePoint,
    void Function({required bool isOverPoint})? setIsOverEndPoint,
  }) {
    final double startDx = position.dx - startXCoord;
    final double overlapDistance = startDx.abs();

    // To check if the points are on top of each other
    if (_isPointOverlapped && overlapDistance <= _markerRadius) {
      setIsOverEndPoint!(isOverPoint: true);
      setIsOverStartPoint(isOverPoint: false);
      return true;
    }

    // Calculate the difference between the start Point and the tap point.
    final double startDy = position.dy - _rectCenter;

    config as TrendDrawingToolConfig;

    final LineStyle lineStyle = config.lineStyle;

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
      setIsOverStartPoint(isOverPoint: true);
    } else {
      setIsOverStartPoint(isOverPoint: false);
    }

    if (endPointDistance <= _markerRadius) {
      setIsOverEndPoint!(isOverPoint: true);
    } else {
      setIsOverEndPoint!(isOverPoint: false);
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

    if (endEdgePoint.epoch != 0) {
      return _isClickedOnRectangleBoundary(_mainRect, position) ||
          _isClickedOnRectangleBoundary(_middleRect, position) ||
          startPointDistance <= _markerRadius ||
          endPointDistance <= _markerRadius ||
          (lineHeight <= lineStyle.thickness + 6 &&
              position.dx > startXCoord &&
              position.dx < endXCoord);
    }
    return false;
  }
}
