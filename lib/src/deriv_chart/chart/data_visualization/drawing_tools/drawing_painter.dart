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

  /// Callback for when drawing is moved.
  final void Function({bool isDrawingMoved}) onMoveDrawing;
}

class _DrawingPainterState extends State<DrawingPainter> {
  bool _isDrawingDragged = false;
  final DraggableEdgePoint _draggableStartPoint = DraggableEdgePoint();
  final DraggableEdgePoint _draggableEndPoint = DraggableEdgePoint();

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();

    void _onPanUpdate(DragUpdateDetails details) {
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

    return widget.drawingData != null
        ? GestureDetector(
            onLongPressDown: (LongPressDownDetails details) {
              widget.onMoveDrawing(isDrawingMoved: true);
            },
            onLongPressUp: () {
              widget.onMoveDrawing(isDrawingMoved: false);
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
                isDrawingDragged: _isDrawingDragged,
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
    required this.isDrawingDragged,
    required this.draggableStartPoint,
    this.draggableEndPoint,
  });

  final DrawingData drawingData;
  final ChartTheme theme;
  double Function(int x) epochToX;
  double Function(double y) quoteToY;
  bool isDrawingDragged;
  DraggableEdgePoint draggableStartPoint;
  DraggableEdgePoint? draggableEndPoint;

  @override
  void paint(Canvas canvas, Size size) {
    for (final Drawing drawing in drawingData.drawings) {
      drawing.onPaint(
        canvas,
        size,
        theme,
        epochToX,
        quoteToY,
        drawingData.config!,
        draggableStartPoint,
        isDrawingDragged: isDrawingDragged,
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
    for (final Drawing drawing in drawingData.drawings) {
      if (drawing.hitTest(
        position,
        epochToX,
        quoteToY,
        drawingData.config!,
        draggableStartPoint,
        isDrawingDragged: isDrawingDragged,
        draggableEndPoint: draggableEndPoint,
      )) {
        return true;
      }
    }
    return false;
  }
}
