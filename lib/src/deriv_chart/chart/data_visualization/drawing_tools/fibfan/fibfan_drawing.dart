import 'dart:math';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/fibfan/fibfan_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/extensions.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/vector.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/fibfan/label.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/line_vector_drawing_mixin.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'fibfan_drawing.g.dart';

/// Fibfan drawing tool.
@JsonSerializable()
class FibfanDrawing extends Drawing with LineVectorDrawingMixin {
  /// Initializes
  FibfanDrawing({
    required this.drawingPart,
    this.startEdgePoint = const EdgePoint(),
    this.endEdgePoint = const EdgePoint(),
    this.exceedStart = false,
    this.exceedEnd = false,
  });

  /// Initializes from JSON.
  factory FibfanDrawing.fromJson(Map<String, dynamic> json) =>
      _$FibfanDrawingFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FibfanDrawingToJson(this)
    ..putIfAbsent(Drawing.classNameKey, () => nameKey);

  /// Key of drawing tool name property in JSON.
  static const String nameKey = 'FibfanDrawing';

  /// Part of a drawing: 'marker' or 'line'
  final DrawingParts drawingPart;

  /// Starting point of drawing
  final EdgePoint startEdgePoint;

  /// Ending point of drawing
  final EdgePoint endEdgePoint;

  /// If the line pass the start point.
  final bool exceedStart;

  /// If the line pass the end point.
  final bool exceedEnd;

  /// Marker radius.
  final double markerRadius = 10;

  Vector _zeroDegreeVector = const Vector.zero();
  Vector _initialInnerVector = const Vector.zero();
  Vector _middleInnerVector = const Vector.zero();
  Vector _finalInnerVector = const Vector.zero();
  Vector _baseVector = const Vector.zero();

  /// Keeps the latest position of the start and end point of drawing
  Point? _startPoint, _endPoint;

  /// Check if the vector is hit
  bool isVectorHit(
    Vector vector,
    Offset position,
    LineStyle lineStyle,
  ) {
    final double _lineLength =
        sqrt(pow(vector.y1 - vector.y0, 2) + pow(vector.x1 - vector.x0, 2));

    /// Computes the distance between a point and a line which should be less
    /// than the line thickness + 6 to make sure the user can easily click on
    final double _distance = ((vector.y1 - vector.y0) * position.dx -
            (vector.x1 - vector.x0) * position.dy +
            vector.x1 * vector.y0 -
            vector.y1 * vector.x0) /
        sqrt(pow(vector.y1 - vector.y0, 2) + pow(vector.x1 - vector.x0, 2));

    final double _xDistToStart = position.dx - vector.x0;
    final double _yDistToStart = position.dy - vector.y0;

    /// Limit the detection to start and end point of the line
    final double _dotProduct = (_xDistToStart * (vector.x1 - vector.x0) +
            _yDistToStart * (vector.y1 - vector.y0)) /
        _lineLength;

    final bool _isWithinRange = _dotProduct > 0 && _dotProduct < _lineLength;

    return _isWithinRange && _distance.abs() <= lineStyle.thickness + 6;
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

  /// Draw the shaded area between two vectors
  void _drawTriangle(
    Canvas canvas,
    DrawingPaintStyle paint,
    FibfanDrawingToolConfig config,
    Vector endVector,
  ) {
    final LineStyle fillStyle = config.fillStyle;
    final Path path = getTrianglePath(_baseVector, endVector);

    canvas.drawPath(
        path,
        paint.fillPaintStyle(
          fillStyle.color,
          fillStyle.thickness,
        ));
  }

// This condition will always return true since Fibfan drawing,
// will always be out of chart's viewport considering it
// expand infinitely.
  @override
  bool needsRepaint(
    int leftEpoch,
    int rightEpoch,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableMiddlePoint,
    DraggableEdgePoint? draggableEndPoint,
  }) =>
      true;

  // Paint the label
  @override
  void onLabelPaint(
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
  ) {}

  /// Paint the line
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
    final DrawingPaintStyle paint = DrawingPaintStyle();
    config as FibfanDrawingToolConfig;

    final LineStyle lineStyle = config.lineStyle;
    final Paint linePaintStyle =
        paint.linePaintStyle(lineStyle.color, lineStyle.thickness);
    final List<EdgePoint> edgePoints = config.edgePoints;

    _startPoint = updatePositionCallback(edgePoints.first, draggableStartPoint);
    if (edgePoints.length > 1) {
      _endPoint = updatePositionCallback(edgePoints.last, draggableEndPoint!);
    } else {
      _endPoint = updatePositionCallback(endEdgePoint, draggableEndPoint!);
    }

    final double startXCoord = _startPoint!.x;
    final double startQuoteToY = _startPoint!.y;

    final double endXCoord = _endPoint!.x;
    final double endQuoteToY = _endPoint!.y;

    if (drawingPart == DrawingParts.marker) {
      if (edgePoints.length == 1) {
        /// Draw first point
        canvas.drawCircle(
            Offset(startXCoord, startQuoteToY),
            markerRadius,
            drawingData.shouldHighlight
                ? paint.glowyCirclePaintStyle(lineStyle.color)
                : paint.transparentCirclePaintStyle());
      }
    } else if (drawingPart == DrawingParts.line) {
      /// Draw the shaded area between two vectors
      Vector _getLineVector(
        double _endXCoord,
        double _startQuoteToY,
      ) =>
          getLineVector(
            startXCoord,
            startQuoteToY,
            _endXCoord,
            _startQuoteToY,
            exceedEnd: true,
          );

      /// Defines the degree of initial inner vector from the base vector
      const double _initialVectorDegree = 0.618;

      /// Defines the degree of middle inner vector from the  base vector
      const double _middleVectorDegree = 0.5;

      /// Defines the degree of final inner vector from the base vector
      const double _finalVectorDegree = 0.382;

      /// Add vectors
      _zeroDegreeVector = _getLineVector(endXCoord, endQuoteToY);
      _initialInnerVector = _getLineVector(
        endXCoord,
        ((endQuoteToY - startQuoteToY) * _initialVectorDegree) + startQuoteToY,
      );

      _middleInnerVector = _getLineVector(
        endXCoord,
        ((endQuoteToY - startQuoteToY) * _middleVectorDegree) + startQuoteToY,
      );
      _finalInnerVector = _getLineVector(
        endXCoord,
        ((endQuoteToY - startQuoteToY) * _finalVectorDegree) + startQuoteToY,
      );
      _baseVector = _getLineVector(endXCoord, startQuoteToY);

      /// Draw shadows
      _drawTriangle(canvas, paint, config, _zeroDegreeVector);
      _drawTriangle(canvas, paint, config, _initialInnerVector);
      _drawTriangle(canvas, paint, config, _middleInnerVector);
      _drawTriangle(canvas, paint, config, _finalInnerVector);

      /// Draw markers again to hide their overlap with shadows
      /// The second cicle is getting created here as the lines and
      /// second marker are getting created at same time
      canvas
        ..drawCircle(
            Offset(startXCoord, startQuoteToY),
            markerRadius,
            drawingData.shouldHighlight
                ? paint.glowyCirclePaintStyle(lineStyle.color)
                : paint.transparentCirclePaintStyle())
        ..drawCircle(
            Offset(endXCoord, endQuoteToY),
            markerRadius,
            drawingData.shouldHighlight
                ? paint.glowyCirclePaintStyle(lineStyle.color)
                : paint.transparentCirclePaintStyle())

        /// Draw vectors
        ..drawLine(
          Offset(_baseVector.x0, _baseVector.y0),
          Offset(_baseVector.x1, _baseVector.y1),
          linePaintStyle,
        )
        ..drawLine(
          Offset(_finalInnerVector.x0, _finalInnerVector.y0),
          Offset(_finalInnerVector.x1, _finalInnerVector.y1),
          linePaintStyle,
        )
        ..drawLine(
          Offset(_middleInnerVector.x0, _middleInnerVector.y0),
          Offset(_middleInnerVector.x1, _middleInnerVector.y1),
          linePaintStyle,
        )
        ..drawLine(
          Offset(_initialInnerVector.x0, _initialInnerVector.y0),
          Offset(_initialInnerVector.x1, _initialInnerVector.y1),
          linePaintStyle,
        )
        ..drawLine(
          Offset(_zeroDegreeVector.x0, _zeroDegreeVector.y0),
          Offset(_zeroDegreeVector.x1, _zeroDegreeVector.y1),
          linePaintStyle,
        );

      /// Draw labels
      Label(
        startXCoord: startXCoord.toInt(),
        endXCoord: endXCoord.toInt(),
      )
        ..drawLabel(canvas, size, lineStyle, zeroDegreeVectorPercentage,
            _zeroDegreeVector)
        ..drawLabel(canvas, size, lineStyle, initialInnerVectorPercentage,
            _initialInnerVector)
        ..drawLabel(canvas, size, lineStyle, middleInnerVectorPercentage,
            _middleInnerVector)
        ..drawLabel(canvas, size, lineStyle, finalInnerVectorPercentage,
            _finalInnerVector)
        ..drawLabel(canvas, size, lineStyle, baseVectorPercentage, _baseVector);
    }
  }

  /// Calculation for detemining whether a user's touch or click intersects
  /// with any of the painted areas on the screen, for any of the edge points
  /// it will set "isDragged" to determine which point is clicked
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
    final LineStyle lineStyle = config.toJson()['lineStyle'];
    bool _isVectorHit(Vector vector) =>
        isVectorHit(vector, position, lineStyle);

    /// Check if start point clicked
    if (_startPoint!.isClicked(position, markerRadius)) {
      setIsOverStartPoint(isOverPoint: true);
    } else {
      setIsOverStartPoint(isOverPoint: false);
    }

    /// Check if end point clicked
    if (_endPoint!.isClicked(position, markerRadius)) {
      setIsOverEndPoint!(isOverPoint: true);
    } else {
      setIsOverEndPoint!(isOverPoint: false);
    }
    return _isVectorHit(_baseVector) ||
        _isVectorHit(_finalInnerVector) ||
        _isVectorHit(_middleInnerVector) ||
        _isVectorHit(_initialInnerVector) ||
        _isVectorHit(_zeroDegreeVector) ||
        (_startPoint!.isClicked(position, markerRadius) ||
            _endPoint!.isClicked(position, markerRadius));
  }
}
