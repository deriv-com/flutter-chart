import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
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
    required this.selectedDrawingTool,
    Key? key,
  }) : super(key: key);

  /// Selected drawing tool.
  final DrawingToolConfig? selectedDrawingTool;

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
  DraggableEdgePoint _draggableStartPoint = DraggableEdgePoint();
  DraggableEdgePoint _draggableMiddlePoint = DraggableEdgePoint();
  DraggableEdgePoint _draggableEndPoint = DraggableEdgePoint();
  Offset? _previousPosition;

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();

    void _onPanUpdate(DragUpdateDetails details) {
      if (widget.drawingData!.isSelected &&
          widget.drawingData!.isDrawingFinished) {
        setState(() {
          _isDrawingDragged = details.delta != Offset.zero;

          _draggableStartPoint = _draggableStartPoint.copyWith(
            isDrawingDragged: _isDrawingDragged,
          )..updatePositionWithLocalPositions(
              details.delta,
              xAxis,
              widget.quoteFromCanvasY,
              widget.quoteToCanvasY,
              isOtherEndDragged: _draggableEndPoint.isDragged ||
                  _draggableMiddlePoint.isDragged,
            );
          _draggableMiddlePoint = _draggableMiddlePoint.copyWith(
            isDrawingDragged: _isDrawingDragged,
          )..updatePositionWithLocalPositions(
              details.delta,
              xAxis,
              widget.quoteFromCanvasY,
              widget.quoteToCanvasY,
              isOtherEndDragged: _draggableEndPoint.isDragged ||
                  _draggableStartPoint.isDragged,
            );

          _draggableEndPoint = _draggableEndPoint.copyWith(
            isDrawingDragged: _isDrawingDragged,
          )..updatePositionWithLocalPositions(
              details.delta,
              xAxis,
              widget.quoteFromCanvasY,
              widget.quoteToCanvasY,
              isOtherEndDragged: _draggableStartPoint.isDragged ||
                  _draggableMiddlePoint.isDragged,
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
        ? RepaintBoundary(
            child: GestureDetector(
              onTapUp: (TapUpDetails details) {
                widget.setIsDrawingSelected(widget.drawingData!);
                _updateDrawingsMovement();
              },
              onLongPressDown: (LongPressDownDetails details) {
                widget.onMoveDrawing(isDrawingMoved: true);
                _previousPosition = details.localPosition;
                _updateDrawingsMovement();
              },
              onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
                final DragUpdateDetails dragDetails =
                    convertLongPressToDrag(details, _previousPosition);
                _previousPosition = details.localPosition;

                _onPanUpdate(dragDetails);
                _updateDrawingsMovement();
              },
              onLongPressUp: () {
                widget.onMoveDrawing(isDrawingMoved: false);
                _draggableStartPoint = _draggableStartPoint.copyWith(
                  isDragged: false,
                );
                _draggableMiddlePoint = _draggableMiddlePoint.copyWith(
                  isDragged: false,
                );
                _draggableEndPoint = _draggableEndPoint.copyWith(
                  isDragged: false,
                );
                _updateDrawingsMovement();
              },
              onPanStart: (DragStartDetails details) {
                widget.onMoveDrawing(isDrawingMoved: true);
                _updateDrawingsMovement();
              },
              onPanUpdate: (DragUpdateDetails details) {
                _onPanUpdate(details);
                _updateDrawingsMovement();
              },
              onPanEnd: (DragEndDetails details) {
                setState(() {
                  _draggableStartPoint = _draggableStartPoint.copyWith(
                    isDragged: false,
                  );
                  _draggableMiddlePoint = _draggableMiddlePoint.copyWith(
                    isDragged: false,
                  );
                  _draggableEndPoint = _draggableEndPoint.copyWith(
                    isDragged: false,
                  );
                });
                widget.onMoveDrawing(isDrawingMoved: false);
                _updateDrawingsMovement();
              },
              child: CustomPaint(
                foregroundPainter: _DrawingPainter(
                  drawingData: widget.drawingData!,
                  theme: context.watch<ChartTheme>(),
                  epochToX: xAxis.xFromEpoch,
                  quoteToY: widget.quoteToCanvasY,
                  draggableStartPoint: _draggableStartPoint,
                  draggableMiddlePoint: _draggableMiddlePoint,
                  isDrawingToolSelected: widget.selectedDrawingTool != null,
                  draggableEndPoint: _draggableEndPoint,
                  leftEpoch: xAxis.leftBoundEpoch,
                  rightEpoch: xAxis.rightBoundEpoch,
                  updatePositionCallback: (
                    EdgePoint edgePoint,
                    DraggableEdgePoint draggableEdgePoint,
                  ) =>
                      draggableEdgePoint.updatePosition(
                    edgePoint.epoch,
                    edgePoint.quote,
                    xAxis.xFromEpoch,
                    widget.quoteToCanvasY,
                  ),
                  setIsStartPointDragged: ({required bool isDragged}) {
                    _draggableStartPoint =
                        _draggableStartPoint.copyWith(isDragged: isDragged);
                  },
                  setIsMiddlePointDragged: ({required bool isDragged}) {
                    _draggableMiddlePoint =
                        _draggableMiddlePoint.copyWith(isDragged: isDragged);
                  },
                  setIsEndPointDragged: ({required bool isDragged}) {
                    _draggableEndPoint =
                        _draggableEndPoint.copyWith(isDragged: isDragged);
                  },
                ),
              ),
            ),
          )
        : const SizedBox();
  }

  void _updateDrawingsMovement() {
    if (widget.drawingData == null) {
      return;
    }

    for (final Drawing drawing in widget.drawingData!.drawingParts) {
      drawing.onDrawingMoved(
        widget.drawingData!.series!,
        _draggableStartPoint,
        endPoint: _draggableEndPoint,
      );
    }
  }
}

class _DrawingPainter extends CustomPainter {
  _DrawingPainter({
    required this.drawingData,
    required this.theme,
    required this.epochToX,
    required this.quoteToY,
    required this.draggableStartPoint,
    required this.setIsStartPointDragged,
    required this.updatePositionCallback,
    required this.leftEpoch,
    required this.rightEpoch,
    this.isDrawingToolSelected = false,
    this.draggableMiddlePoint,
    this.draggableEndPoint,
    this.setIsMiddlePointDragged,
    this.setIsEndPointDragged,
  });

  final DrawingData drawingData;
  final ChartTheme theme;
  final bool isDrawingToolSelected;
  final double Function(int x) epochToX;
  final double Function(double y) quoteToY;
  final DraggableEdgePoint draggableStartPoint;
  final DraggableEdgePoint? draggableMiddlePoint;
  final DraggableEdgePoint? draggableEndPoint;
  final void Function({required bool isDragged}) setIsStartPointDragged;
  final void Function({required bool isDragged})? setIsMiddlePointDragged;
  final void Function({required bool isDragged})? setIsEndPointDragged;
  final Point Function(
    EdgePoint edgePoint,
    DraggableEdgePoint draggableEdgePoint,
  ) updatePositionCallback;

  /// Current left epoch of the chart.
  final int leftEpoch;

  /// Current right epoch of the chart.
  final int rightEpoch;

  @override
  void paint(Canvas canvas, Size size) {
    for (final Drawing drawingPart in drawingData.drawingParts) {
      drawingPart.onPaint(
        canvas,
        size,
        theme,
        epochToX,
        quoteToY,
        drawingData,
        updatePositionCallback,
        draggableStartPoint,
        draggableMiddlePoint: draggableMiddlePoint,
        draggableEndPoint: draggableEndPoint,
      );
    }
  }

  @override
  bool shouldRepaint(_DrawingPainter oldDelegate) => drawingData.shouldRepaint(
        oldDelegate.drawingData,
        leftEpoch,
        rightEpoch,
        draggableStartPoint,
        draggableEndPoint: draggableEndPoint,
      );

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
        setIsStartPointDragged,
        draggableMiddlePoint: draggableMiddlePoint,
        draggableEndPoint: draggableEndPoint,
        setIsMiddlePointDragged: setIsMiddlePointDragged,
        setIsEndPointDragged: setIsEndPointDragged,
      )) {
        if (isDrawingToolSelected) {
          return false;
        }
        return true;
      }
    }

    /// For deselecting the drawing when tapping outside of the drawing.
    drawingData.isSelected = false;
    return false;
  }
}
