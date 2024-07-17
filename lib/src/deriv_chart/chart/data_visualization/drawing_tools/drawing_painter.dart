import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/add_on_config_wrapper.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/y_axis/y_axis_config.dart';
import 'package:deriv_chart/src/misc/debounce.dart';
import 'package:deriv_chart/src/models/tick.dart';
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
    required this.isDrawingMoving,
    required this.selectedDrawingTool,
    required this.onMouseEnter,
    required this.onMouseExit,
    required this.series,
    Key? key,
  }) : super(key: key);

  /// Selected drawing tool.
  final DrawingToolConfig? selectedDrawingTool;

  /// Contains each drawing data
  final DrawingData? drawingData;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteToCanvasY;

  /// Whether a drawing is moved or not.
  final bool isDrawingMoving;

  @override
  _DrawingPainterState createState() => _DrawingPainterState();

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteFromCanvasY;

  /// Callback to check if any single part of a single drawing is moved
  /// regardless of knowing type of the drawing.
  final void Function({bool isDrawingMoved}) onMoveDrawing;

  /// Callback to set if drawing is selected (tapped).
  final void Function(DrawingData drawing) setIsDrawingSelected;

  /// Callback to notify mouse enter over the addon.
  final void Function() onMouseEnter;

  /// Callback to notify mouse exit over the addon.
  final void Function() onMouseExit;

  /// Series of tick
  final DataSeries<Tick> series;
}

class _DrawingPainterState extends State<DrawingPainter> {
  bool _isDrawingDragged = false;
  DraggableEdgePoint _draggableStartPoint = DraggableEdgePoint();
  DraggableEdgePoint _draggableMiddlePoint = DraggableEdgePoint();
  DraggableEdgePoint _draggableEndPoint = DraggableEdgePoint();
  Offset? _previousPosition;
  bool isTouchHeld = false;
  bool isOverStartPoint = false;
  bool isOverMiddlePoint = false;
  bool isOverEndPoint = false;

  final Debounce _updateDebounce = Debounce();

  void _onMouseEnter() {
    setState(() {
      widget.drawingData!.isHovered = true;
    });
    widget.onMouseEnter();
  }

  void _onMouseExit() {
    setState(() {
      widget.drawingData!.isHovered = false;
    });
    widget.onMouseExit();
  }

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();

    final Repository<DrawingToolConfig> repo =
        context.watch<Repository<DrawingToolConfig>>();

    /// In this method, we are updating the restored drawing tool
    /// config with latest data from the chart.
    void updateDrawingToolConfig() {
      _updateDebounce.run(() {
        final DrawingData drawingData = widget.drawingData!;
        final int index = repo.items.indexWhere(
          (AddOnConfigWrapper<DrawingToolConfig> item) =>
              // Use wrapper model class id instead.
              item.addOnConfig.configId == drawingData.id,
        );

        if (index > -1) {
          final AddOnConfigWrapper<DrawingToolConfig> config =
              repo.items[index];

          final AddOnConfigWrapper<DrawingToolConfig> updatedConfig =
              config.copyWith(
            addOnConfig: config.addOnConfig.copyWith(edgePoints: <EdgePoint>[
              _draggableStartPoint.getEdgePoint(),
              // TODO(Bahar-Deriv): Change the way storing edge points
              if (config.addOnConfig.configId!.contains('Channel'))
                _draggableMiddlePoint.getEdgePoint(),
              _draggableEndPoint.getEdgePoint(),
            ]),
          );
          repo.updateAt(index, updatedConfig);
        }
      });
    }

    void _updateDrawingsMovement() {
      if (widget.drawingData == null) {
        return;
      }

      for (final Drawing drawing in widget.drawingData!.drawingParts) {
        drawing.onDrawingMoved(
          xAxis.epochFromX,
          widget.series.entries!,
          _draggableStartPoint,
          middlePoint: _draggableMiddlePoint,
          endPoint: _draggableEndPoint,
        );
      }

      setState(() {});
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
              if (!isTouchHeld && !widget.isDrawingMoving) {
                _onMouseEnter();
              }
            },
            onExit: (PointerExitEvent event) {
              if (!isTouchHeld && !widget.isDrawingMoving) {
                _onMouseExit();
              }
            },
            hitTestBehavior: HitTestBehavior.deferToChild,
            child: RepaintBoundary(
              child: GestureDetector(
                onTapUp: (TapUpDetails details) {
                  isTouchHeld = false;
                  if (details.kind != PointerDeviceKind.mouse) {
                    widget.setIsDrawingSelected(widget.drawingData!);
                    _updateDrawingsMovement();
                  }
                  widget.onMoveDrawing(isDrawingMoved: false);
                },
                onLongPressDown: (LongPressDownDetails details) {
                  if (details.kind == PointerDeviceKind.mouse &&
                      !widget.drawingData!.isSelected) {
                    widget.setIsDrawingSelected(widget.drawingData!);
                  }

                  _draggableStartPoint = _draggableStartPoint.copyWith(
                    isDragged: isOverStartPoint,
                  );

                  _draggableMiddlePoint = _draggableMiddlePoint.copyWith(
                    isDragged: isOverMiddlePoint,
                  );

                  _draggableEndPoint = _draggableEndPoint.copyWith(
                    isDragged: isOverEndPoint,
                  );

                  widget.onMoveDrawing(isDrawingMoved: true);
                  isTouchHeld = true;
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
                  _onMouseExit();
                  isTouchHeld = false;
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
                  isTouchHeld = true;
                  _updateDrawingsMovement();
                },
                onPanUpdate: (DragUpdateDetails details) {
                  _onPanUpdate(details);
                  _updateDrawingsMovement();
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
                  _onMouseExit();
                  _updateDrawingsMovement();
                },
                child: CustomPaint(
                  foregroundPainter: _DrawingPainter(
                    drawingData: widget.drawingData!,
                    series: widget.series,
                    config: repo.items
                        .where((AddOnConfigWrapper<DrawingToolConfig> config) =>
                            // TODO(Ramin): use id from wrapper model instead.
                            config.addOnConfig.configId ==
                            widget.drawingData!.id)
                        .first
                        .addOnConfig,
                    theme: context.watch<ChartTheme>(),
                    epochFromX: xAxis.epochFromX,
                    epochToX: xAxis.xFromEpoch,
                    quoteToY: widget.quoteToCanvasY,
                    quoteFromY: widget.quoteFromCanvasY,
                    draggableStartPoint: _draggableStartPoint,
                    draggableMiddlePoint: _draggableMiddlePoint,
                    isTouchHeld: isTouchHeld,
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
                    setIsOverStartPoint: ({required bool isOverPoint}) {
                      isOverStartPoint = isOverPoint;
                    },
                    setIsOverMiddlePoint: ({required bool isOverPoint}) {
                      isOverMiddlePoint = isOverPoint;
                    },
                    setIsOverEndPoint: ({required bool isOverPoint}) {
                      isOverEndPoint = isOverPoint;
                    },
                  ),
                ),
              ),
            ))
        : const SizedBox();
  }
}

class _DrawingPainter extends CustomPainter {
  _DrawingPainter({
    required this.drawingData,
    required this.series,
    required this.config,
    required this.theme,
    required this.epochFromX,
    required this.epochToX,
    required this.quoteToY,
    required this.quoteFromY,
    required this.draggableStartPoint,
    required this.setIsOverStartPoint,
    required this.updatePositionCallback,
    required this.leftEpoch,
    required this.rightEpoch,
    this.isDrawingToolSelected = false,
    this.isTouchHeld = false,
    this.draggableMiddlePoint,
    this.draggableEndPoint,
    this.setIsOverMiddlePoint,
    this.setIsOverEndPoint,
  });

  final DrawingData drawingData;
  final DataSeries<Tick> series;
  final DrawingToolConfig config;
  final ChartTheme theme;
  final bool isDrawingToolSelected;
  final bool isTouchHeld;
  final int Function(double x) epochFromX;
  final double Function(int x) epochToX;
  final double Function(double y) quoteToY;
  final DraggableEdgePoint draggableStartPoint;
  final DraggableEdgePoint? draggableMiddlePoint;
  final DraggableEdgePoint? draggableEndPoint;
  final void Function({required bool isOverPoint}) setIsOverStartPoint;
  final void Function({required bool isOverPoint})? setIsOverMiddlePoint;
  final void Function({required bool isOverPoint})? setIsOverEndPoint;
  final Point Function(
    EdgePoint edgePoint,
    DraggableEdgePoint draggableEdgePoint,
  ) updatePositionCallback;

  /// Current left epoch of the chart.
  final int leftEpoch;

  /// Current right epoch of the chart.
  final int rightEpoch;

  double Function(double) quoteFromY;

  @override
  void paint(Canvas canvas, Size size) {
    for (final Drawing drawingPart in drawingData.drawingParts) {
      YAxisConfig.instance.yAxisClipping(canvas, size, () {
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
          series,
          updatePositionCallback,
          draggableStartPoint,
          draggableMiddlePoint: draggableMiddlePoint,
          draggableEndPoint: draggableEndPoint,
        );
      });

      drawingPart.onLabelPaint(
        canvas,
        size,
        theme,
        epochFromX,
        quoteFromY,
        epochToX,
        quoteToY,
        config,
        drawingData,
        series,
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
        config,
        draggableStartPoint,
        setIsOverStartPoint,
        draggableMiddlePoint: draggableMiddlePoint,
        draggableEndPoint: draggableEndPoint,
        setIsOverMiddlePoint: setIsOverMiddlePoint,
        setIsOverEndPoint: setIsOverEndPoint,
      )) {
        if (isDrawingToolSelected) {
          return false;
        }
        return true;
      }
    }

    if (!isTouchHeld && drawingData.isDrawingFinished) {
      /// For deselecting the drawing when tapping outside of the drawing.
      drawingData
        ..isSelected = false
        ..isHovered = false;
    }
    return false;
  }
}
