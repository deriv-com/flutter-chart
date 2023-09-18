import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/misc/debounce.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Paints every existing drawing.
class DrawingPainter extends StatefulWidget {
  /// Initializes
  const DrawingPainter({
    required this.drawingData,
    required this.quoteToCanvasY,
    required this.quoteFromCanvasY,
    required this.onMoveDrawing,
    required this.setIsDrawingSelected,
    required this.setIsDrawingHovered,
    required this.selectedDrawingTool,
    required this.onMouseEnter,
    required this.onMouseExit,
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

  /// Callback to set if drawing is selected (tapped).
  final void Function(DrawingData drawing) setIsDrawingHovered;

  /// Callback to notify mouse enter over the addon.
  final void Function(PointerEnterEvent event) onMouseEnter;

  /// Callback to notify mouse exit over the addon.
  final void Function(PointerExitEvent event) onMouseExit;
}

class _DrawingPainterState extends State<DrawingPainter> {
  bool _isDrawingDragged = false;
  DraggableEdgePoint _draggableStartPoint = DraggableEdgePoint();
  DraggableEdgePoint _draggableMiddlePoint = DraggableEdgePoint();
  DraggableEdgePoint _draggableEndPoint = DraggableEdgePoint();
  Offset? _previousPosition;
  bool isTouchHeld = false;

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();

    final Repository<DrawingToolConfig> repo =
        context.watch<Repository<DrawingToolConfig>>();

    /// In this method, we are updating the restored drawing tool
    /// config with latest data from the chart.
    void updateDrawingToolConfig() {
      final Debounce debounce = Debounce();
      final DrawingData drawingData = widget.drawingData!;
      debounce.run(() {
        repo.items.asMap().forEach((int index, DrawingToolConfig element) {
          if (element.toJson()['configId'] == drawingData.toJson()['id']) {
            DrawingToolConfig updatedConfig;

            updatedConfig = element.copyWith(
              edgePoints: <EdgePoint>[
                _draggableStartPoint.getEdgePoint(),
                _draggableMiddlePoint.getEdgePoint(),
                _draggableEndPoint.getEdgePoint(),
              ],
            );

            repo.updateAt(index, updatedConfig);
          }
        });
      });
    }

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

        /// Updating restored DrawingToolConfig with latest data from the chart
        updateDrawingToolConfig();
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
        ? MouseRegion(
            onEnter: (PointerEnterEvent event) {
              if (!widget.drawingData!.isSelected) {
                widget.setIsDrawingHovered(widget.drawingData!);
                widget.onMouseEnter(event);
              }
            },
            onExit: (PointerExitEvent event) {
              widget.onMouseExit(event);
            },
            hitTestBehavior: HitTestBehavior.deferToChild,
            child: GestureDetector(
              onTapDown: (TapDownDetails details) {
                isTouchHeld = true;
                if (!widget.drawingData!.isSelected) {
                  widget.setIsDrawingSelected(widget.drawingData!);
                }
              },
            onTapUp: (TapUpDetails details) {
              widget.setIsDrawingSelected(widget.drawingData!);
                isTouchHeld = false;
            },
            onLongPressDown: (LongPressDownDetails details) {
                isTouchHeld = true;
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
                isTouchHeld = false;
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
            },
            onPanStart: (DragStartDetails details) {
                isTouchHeld = true;
              widget.onMoveDrawing(isDrawingMoved: true);
            },
            onPanUpdate: (DragUpdateDetails details) {
              _onPanUpdate(details);
            },
            onPanEnd: (DragEndDetails details) {
                isTouchHeld = false;
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
            },
            child: CustomPaint(
              foregroundPainter: _DrawingPainter(
                drawingData: widget.drawingData!,
                config: repo.items
                    .where((DrawingToolConfig config) =>
                        config.toJson()['configId'] == widget.drawingData!.id)
                    .first,
                theme: context.watch<ChartTheme>(),
                epochFromX: xAxis.epochFromX,
                epochToX: xAxis.xFromEpoch,
                quoteToY: widget.quoteToCanvasY,
                quoteFromY: widget.quoteFromCanvasY,
                draggableStartPoint: _draggableStartPoint,
                draggableMiddlePoint: _draggableMiddlePoint,
                isDrawingToolSelected: widget.selectedDrawingTool != null,
                  isTouchHeld: isTouchHeld,
                draggableEndPoint: _draggableEndPoint,
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
                    if (isTouchHeld) {
                  _draggableStartPoint =
                      _draggableStartPoint.copyWith(isDragged: isDragged);
                    }
                },
                setIsMiddlePointDragged: ({required bool isDragged}) {
                    if (isTouchHeld) {
                  _draggableMiddlePoint =
                      _draggableMiddlePoint.copyWith(isDragged: isDragged);
                    }
                },
                setIsEndPointDragged: ({required bool isDragged}) {
                    if (isTouchHeld) {
                  _draggableEndPoint =
                      _draggableEndPoint.copyWith(isDragged: isDragged);
                    }
                },
              ),
              size: const Size(double.infinity, double.infinity),
            ),
            ))
        : const SizedBox();
  }
}

class _DrawingPainter extends CustomPainter {
  _DrawingPainter({
    required this.drawingData,
    required this.config,
    required this.theme,
    required this.epochFromX,
    required this.epochToX,
    required this.quoteToY,
    required this.quoteFromY,
    required this.draggableStartPoint,
    required this.setIsStartPointDragged,
    required this.updatePositionCallback,
    this.isTouchHeld = false,
    this.isDrawingToolSelected = false,
    this.draggableMiddlePoint,
    this.draggableEndPoint,
    this.setIsMiddlePointDragged,
    this.setIsEndPointDragged,
  });

  final DrawingData drawingData;
  final DrawingToolConfig config;
  final ChartTheme theme;
  final bool isDrawingToolSelected;
  final int Function(double x) epochFromX;
  final double Function(int x) epochToX;
  final double Function(double y) quoteToY;
  final DraggableEdgePoint draggableStartPoint;
  final DraggableEdgePoint? draggableMiddlePoint;
  final DraggableEdgePoint? draggableEndPoint;
  final bool isTouchHeld;
  final void Function({required bool isDragged}) setIsStartPointDragged;
  final void Function({required bool isDragged})? setIsMiddlePointDragged;
  final void Function({required bool isDragged})? setIsEndPointDragged;
  final Point Function(
    EdgePoint edgePoint,
    DraggableEdgePoint draggableEdgePoint,
  ) updatePositionCallback;

  double Function(double) quoteFromY;
  @override
  void paint(Canvas canvas, Size size) {
    for (final Drawing drawingPart in drawingData.drawingParts) {
      drawingPart.onPaint(
        canvas,
        size,
        theme,
        epochFromX,
        quoteFromY,
        epochToX,
        quoteToY,
        config,
        drawingData,
        updatePositionCallback,
        draggableStartPoint,
        draggableMiddlePoint: draggableMiddlePoint,
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
        config,
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
    if (!isTouchHeld && drawingData.isDrawingFinished) {
    /// For deselecting the drawing when tapping outside of the drawing.
    drawingData.isSelected = false;
    }
    return false;
  }
}
