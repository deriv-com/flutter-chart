import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
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
}

class _DrawingPainterState extends State<DrawingPainter> {
  bool _isDrawingDragged = false;
  final DraggableEdgePoint _draggableInitialPoint = DraggableEdgePoint();
  final DraggableEdgePoint _draggableFinalPoint = DraggableEdgePoint();

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();

    return widget.drawingData != null
        ? GestureDetector(
            onPanUpdate: (DragUpdateDetails details) {
              Offset getFixedPosition(Offset position,
                      {required bool isTouched}) =>
                  Offset(xAxis.xFromEpoch(position.dx.toInt()),
                      widget.quoteToCanvasY(position.dy)) +
                  (isTouched ? Offset.zero : details.delta);

              final Offset startFixedPosition = getFixedPosition(
                  _draggableInitialPoint.draggedPosition,
                  isTouched: _draggableFinalPoint.isDragged);

              final Offset endFixedPosition = getFixedPosition(
                  _draggableFinalPoint.draggedPosition,
                  isTouched: _draggableInitialPoint.isDragged);

              setState(() {
                _isDrawingDragged = details.delta != Offset.zero;

                _draggableInitialPoint.draggedPosition = Offset(
                    xAxis.epochFromX(startFixedPosition.dx).toDouble(),
                    widget.quoteFromCanvasY(startFixedPosition.dy));

                _draggableFinalPoint.draggedPosition = Offset(
                    xAxis.epochFromX(endFixedPosition.dx).toDouble(),
                    widget.quoteFromCanvasY(endFixedPosition.dy));
              });
            },
            onPanEnd: (DragEndDetails details) {
              setState(() {
                _draggableInitialPoint.isDragged = false;
                _draggableFinalPoint.isDragged = false;
              });
            },
            child: CustomPaint(
              foregroundPainter: _DrawingPainter(
                drawingData: widget.drawingData!,
                theme: context.watch<ChartTheme>(),
                epochToX: xAxis.xFromEpoch,
                quoteToY: widget.quoteToCanvasY,
                isDrawingDragged: _isDrawingDragged,
                draggableInitialPoint: _draggableInitialPoint,
                draggableFinalPoint: _draggableFinalPoint,
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
    required this.draggableInitialPoint,
    this.draggableFinalPoint,
  });

  final DrawingData drawingData;
  final ChartTheme theme;
  double Function(int x) epochToX;
  double Function(double y) quoteToY;
  bool isDrawingDragged;
  DraggableEdgePoint draggableInitialPoint;
  DraggableEdgePoint? draggableFinalPoint;

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
        isDrawingDragged,
        draggableInitialPoint,
        draggableFinalPoint: draggableFinalPoint,
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
        isDrawingDragged,
        draggableInitialPoint,
        draggableFinalPoint: draggableFinalPoint,
      )) {
        return true;
      }
    }
    return false;
  }
}
