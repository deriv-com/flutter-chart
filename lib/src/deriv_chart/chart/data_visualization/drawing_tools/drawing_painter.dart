import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deriv_chart/deriv_chart.dart';

/// Paints every existing drawing.
class DrawingPainter extends StatefulWidget {
  /// Initializes
  const DrawingPainter({
    required this.drawingData,
    required this.quoteToCanvasY,
    required this.quoteFromCanvasY,
    required this.onMoveDrawing,
    required this.setIsDrawingSelected,
    Key? key,
  }) : super(key: key);

  /// Contains each drawing data
  final DrawingData? drawingData;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteToCanvasY;

  @override
  _DrawingPainterState createState() => _DrawingPainterState();

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteFromCanvasY;

  /// Callback to check if any single part of a single drawing is moved
  /// regardless of knowing type of the drawing.
  final void Function({bool isDrawingMoved}) onMoveDrawing;

  /// Callback to set if drawing is selected (tapped).
  final void Function(DrawingData drawing) setIsDrawingSelected;
}

class _DrawingPainterState extends State<DrawingPainter> {
  bool _isDrawingDragged = false;
  final DraggableEdgePoint _draggableStartPoint = DraggableEdgePoint();
  final DraggableEdgePoint _draggableEndPoint = DraggableEdgePoint();
  Offset? _previousPosition;

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();

    void _onPanUpdate(DragUpdateDetails details) {
      if (widget.drawingData!.isSelected &&
          widget.drawingData!.isDrawingFinished) {
        setState(() {
          _isDrawingDragged = details.delta != Offset.zero;
          _draggableStartPoint
            ..isDrawingDragged = _isDrawingDragged
            ..updatePositionWithLocalPositions(
              details.delta,
              xAxis,
              widget.quoteFromCanvasY,
              widget.quoteToCanvasY,
              isOtherEndDragged: _draggableEndPoint.isDragged,
            );
          _draggableEndPoint
            ..isDrawingDragged = _isDrawingDragged
            ..updatePositionWithLocalPositions(
              details.delta,
              xAxis,
              widget.quoteFromCanvasY,
              widget.quoteToCanvasY,
              isOtherEndDragged: _draggableStartPoint.isDragged,
            );
        });
      }
    }

    DragUpdateDetails convertLongPressToDrag(
        LongPressMoveUpdateDetails longPressDetails, Offset? previousPosition) {
      final Offset delta = longPressDetails.localPosition - previousPosition!;
      return DragUpdateDetails(
        delta: delta,
        globalPosition: longPressDetails.globalPosition,
        localPosition: longPressDetails.localPosition,
      );
    }

    return widget.drawingData != null
        ? GestureDetector(
            onTapUp: (TapUpDetails details) {
              widget.setIsDrawingSelected(widget.drawingData!);
            },
            onLongPressDown: (LongPressDownDetails details) {
              widget.onMoveDrawing(isDrawingMoved: true);
              _previousPosition = details.localPosition;
            },
            onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
              final DragUpdateDetails dragDetails =
                  convertLongPressToDrag(details, _previousPosition);
              _previousPosition = details.localPosition;

              _onPanUpdate(dragDetails);
            },
            onLongPressUp: () {
              widget.onMoveDrawing(isDrawingMoved: false);
              _draggableStartPoint.isDragged = false;
              _draggableEndPoint.isDragged = false;
            },
            onPanStart: (DragStartDetails details) {
              widget.onMoveDrawing(isDrawingMoved: true);
            },
            onPanUpdate: (DragUpdateDetails details) {
              _onPanUpdate(details);
            },
            onPanEnd: (DragEndDetails details) {
              setState(() {
                _draggableStartPoint.isDragged = false;
                _draggableEndPoint.isDragged = false;
              });
              widget.onMoveDrawing(isDrawingMoved: false);
            },
            child: CustomPaint(
              foregroundPainter: _DrawingPainter(
                drawingData: widget.drawingData!,
                theme: context.watch<ChartTheme>(),
                epochToX: xAxis.xFromEpoch,
                quoteToY: widget.quoteToCanvasY,
                quoteFromY: widget.quoteFromCanvasY,
                draggableStartPoint: _draggableStartPoint,
                draggableEndPoint: _draggableEndPoint,
              ),
              size: const Size(double.infinity, double.infinity),
            ),
          )
        : const SizedBox();
  }
}

class _DrawingPainter extends CustomPainter {
  _DrawingPainter({
    required this.drawingData,
    required this.theme,
    required this.epochToX,
    required this.quoteToY,
    required this.quoteFromY,
    required this.draggableStartPoint,
    this.draggableEndPoint,
  });

  final DrawingData drawingData;
  final ChartTheme theme;
  double Function(int x) epochToX;
  double Function(double y) quoteToY;
  DraggableEdgePoint draggableStartPoint;
  DraggableEdgePoint? draggableEndPoint;

  double Function(double) quoteFromY;
  @override
  void paint(Canvas canvas, Size size) {
    for (final Drawing drawingPart in drawingData.drawingParts) {
      drawingPart.onPaint(
        canvas,
        size,
        theme,
        epochToX,
        quoteToY,
        quoteFromY,
        drawingData,
        draggableStartPoint,
        draggableEndPoint: draggableEndPoint,
      );
    }
  }

  @override
  bool shouldRepaint(_DrawingPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_DrawingPainter oldDelegate) => false;

  @override
  bool hitTest(Offset position) {
    for (final Drawing drawingPart in drawingData.drawingParts) {
      if (drawingPart.hitTest(
        position,
        epochToX,
        quoteToY,
        drawingData.config,
        draggableStartPoint,
        draggableEndPoint: draggableEndPoint,
      )) {
        return true;
      }
    }

    /// For deselecting the drawing when tapping outside of the drawing.
    drawingData.isSelected = false;
    return false;
  }
}
