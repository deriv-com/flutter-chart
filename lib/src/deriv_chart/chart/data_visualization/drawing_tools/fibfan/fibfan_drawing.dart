import 'dart:math';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/fibfan/fibfan_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/vector.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/fibfan/label.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';

/// Fibfan drawing tool.
class FibfanDrawing extends Drawing {
  /// Initializes
  FibfanDrawing({
    required this.drawingPart,
    this.startEdgePoint = const EdgePoint(),
    this.endEdgePoint = const EdgePoint(),
    this.exceedStart = false,
    this.exceedEnd = false,
  });

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

  Vector _baseVector = const Vector.zero();
  Vector _topVector = const Vector.zero();
  Vector _initialInnerVector = const Vector.zero();
  Vector _middleInnerVector = const Vector.zero();
  Vector _topInnerVector = const Vector.zero();

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

  /// Draw the shaded area between two vectors
  void _drawTriangle(
    Canvas canvas,
    DrawingPaintStyle paint,
    FibfanDrawingToolConfig config,
    Vector endVector,
  ) {
    final LineStyle fillStyle = config.fillStyle;
    final Path path = getTrianglePath(_baseVector, endVector);

    canvas.drawPath(path, paint.fillPaintStyle(fillStyle.color));
  }

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
    final FibfanDrawingToolConfig config =
        drawingData.config as FibfanDrawingToolConfig;
    final LineStyle lineStyle = config.lineStyle;
    final Paint linePaintStype =
        paint.linePaintStyle(lineStyle.color, lineStyle.thickness);

    _startPoint = draggableStartPoint.updatePosition(
      startEdgePoint.epoch,
      startEdgePoint.quote,
      epochToX,
      quoteToY,
    );
    _endPoint = draggableEndPoint!.updatePosition(
      endEdgePoint.epoch,
      endEdgePoint.quote,
      epochToX,
      quoteToY,
    );

    final double startXCoord = _startPoint!.x;
    final double startQuoteToY = _startPoint!.y;

    final double endXCoord = _endPoint!.x;
    final double endQuoteToY = _endPoint!.y;

    if (drawingPart == DrawingParts.marker) {
      if (endEdgePoint.epoch != 0 && endQuoteToY != 0) {
        /// Draw second point
        canvas.drawCircle(
            Offset(endXCoord, endQuoteToY),
            markerRadius,
            drawingData.isSelected
                ? paint.glowyCirclePaintStyle(lineStyle.color)
                : paint.transparentCirclePaintStyle());
      } else if (startEdgePoint.epoch != 0 && startQuoteToY != 0) {
        /// Draw first point
        canvas.drawCircle(
            Offset(startXCoord, startQuoteToY),
            markerRadius,
            drawingData.isSelected
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

      /// Add vectors
      _baseVector = _getLineVector(endXCoord, startQuoteToY);
      _topVector = _getLineVector(endXCoord, endQuoteToY);
      _initialInnerVector = _getLineVector(
        endXCoord,
        ((endQuoteToY - startQuoteToY) * 0.382) + startQuoteToY,
      );
      _middleInnerVector = _getLineVector(
        endXCoord,
        ((endQuoteToY - startQuoteToY) * 0.5) + startQuoteToY,
      );
      _topInnerVector = _getLineVector(
        endXCoord,
        ((endQuoteToY - startQuoteToY) * 0.618) + startQuoteToY,
      );

      /// Draw vectors
      canvas
        ..drawLine(
          Offset(_baseVector.x0, _baseVector.y0),
          Offset(_baseVector.x1, _baseVector.y1),
          linePaintStype,
        )
        ..drawLine(
          Offset(_initialInnerVector.x0, _initialInnerVector.y0),
          Offset(_initialInnerVector.x1, _initialInnerVector.y1),
          linePaintStype,
        )
        ..drawLine(
          Offset(_middleInnerVector.x0, _middleInnerVector.y0),
          Offset(_middleInnerVector.x1, _middleInnerVector.y1),
          linePaintStype,
        )
        ..drawLine(
          Offset(_topInnerVector.x0, _topInnerVector.y0),
          Offset(_topInnerVector.x1, _topInnerVector.y1),
          linePaintStype,
        )
        ..drawLine(
          Offset(_topVector.x0, _topVector.y0),
          Offset(_topVector.x1, _topVector.y1),
          linePaintStype,
        );

      final Label _label = Label(
        startEpoch: startXCoord.toInt(),
        endEpoch: endXCoord.toInt(),
      );

      /// Draw labels
      _label
        ..drawLabel(canvas, lineStyle, '0%', _topVector)
        ..drawLabel(canvas, lineStyle, '38.2%', _initialInnerVector)
        ..drawLabel(canvas, lineStyle, '50%', _middleInnerVector)
        ..drawLabel(canvas, lineStyle, '61.8%', _topInnerVector)
        ..drawLabel(canvas, lineStyle, '100%', _baseVector);

      /// Draw shadows
      _drawTriangle(canvas, paint, config, _topVector);
      _drawTriangle(canvas, paint, config, _initialInnerVector);
      _drawTriangle(canvas, paint, config, _middleInnerVector);
      _drawTriangle(canvas, paint, config, _topInnerVector);
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
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableEndPoint,
  }) {
    final LineStyle lineStyle = config.toJson()['lineStyle'];
    bool _isVectorHit(Vector vector) =>
        isVectorHit(vector, position, lineStyle);

    draggableStartPoint.isDragged = false;
    draggableEndPoint!.isDragged = false;

    /// Check if start point clicked
    if (_startPoint!.isClicked(position, markerRadius)) {
      draggableStartPoint.isDragged = true;
    }

    /// Check if end point clicked
    if (_endPoint!.isClicked(position, markerRadius)) {
      draggableEndPoint.isDragged = true;
    }
    return _isVectorHit(_baseVector) ||
        _isVectorHit(_initialInnerVector) ||
        _isVectorHit(_middleInnerVector) ||
        _isVectorHit(_topInnerVector) ||
        _isVectorHit(_topVector) ||
        (draggableStartPoint.isDragged || draggableEndPoint.isDragged);
  }
}
