import 'dart:ui' as ui;
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/fibfan/fibfan_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/extensions/extensions.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/drawing_adding_preview.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/fibfan/helpers.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/widgets/color_picker.dart';
import 'package:deriv_chart/src/models/axis_range.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/design_tokens/core_design_tokens.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../enums/drawing_tool_state.dart';
import '../../helpers/paint_helpers.dart';
import '../../helpers/types.dart';
import '../../interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import '../../interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import '../drawing_v2.dart';
import '../interactable_drawing.dart';
import 'fibfan_adding_preview_desktop.dart';
import 'fibfan_adding_preview_mobile.dart';

/// Interactable drawing for Fibonacci Fan drawing tool.
class FibfanInteractableDrawing
    extends InteractableDrawing<FibfanDrawingToolConfig> {
  /// Initializes [FibfanInteractableDrawing].
  FibfanInteractableDrawing({
    required FibfanDrawingToolConfig config,
    required this.startPoint,
    required this.endPoint,
    required super.drawingContext,
    required super.getDrawingState,
  }) : super(drawingConfig: config);

  /// Start point of the fan.
  EdgePoint? startPoint;

  /// End point of the fan.
  EdgePoint? endPoint;

  /// Tracks which point is being dragged, if any
  ///
  /// [null]: dragging the whole fan.
  /// [true]: dragging the start point.
  /// [false]: dragging the end point.
  bool? isDraggingStartPoint;

  Offset? _hoverPosition;

  @override
  void onHover(PointerHoverEvent event, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    _hoverPosition = event.localPosition;
  }

  @override
  void onDragStart(
    DragStartDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    if (startPoint == null || endPoint == null) {
      return;
    }

    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );

    final Offset endOffset = Offset(
      epochToX(endPoint!.epoch),
      quoteToY(endPoint!.quote),
    );

    // Check if the drag is starting on one of the endpoints
    final double startDistance = (details.localPosition - startOffset).distance;
    final double endDistance = (details.localPosition - endOffset).distance;

    // If the drag is starting on the start point
    if (startDistance <= hitTestMargin) {
      isDraggingStartPoint = true;
      return;
    }

    // If the drag is starting on the end point
    if (endDistance <= hitTestMargin) {
      isDraggingStartPoint = false;
      return;
    }

    // Check if the drag is on any of the fan lines
    if (_hitTestFanLines(details.localPosition, epochToX, quoteToY)) {
      isDraggingStartPoint = null; // Dragging the whole fan
      return;
    }
  }

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    if (startPoint == null || endPoint == null) {
      return false;
    }

    final isNotSelected = !state.contains(DrawingToolState.selected);
    final isOutsideContent = offset.dx > drawingContext.contentSize.width;

    if (isNotSelected && isOutsideContent) {
      return false;
    }

    // Convert start and end points from epoch/quote to screen coordinates
    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );
    final Offset endOffset = Offset(
      epochToX(endPoint!.epoch),
      quoteToY(endPoint!.quote),
    );

    // Check if the pointer is near either endpoint
    final double startDistance = (offset - startOffset).distance;
    final double endDistance = (offset - endOffset).distance;

    if (startDistance <= hitTestMargin || endDistance <= hitTestMargin) {
      return true;
    }

    // Check if the pointer is near any of the fan lines
    return _hitTestFanLines(offset, epochToX, quoteToY);
  }

  /// Helper method to test if a point hits any of the fan lines
  bool _hitTestFanLines(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    if (startPoint == null || endPoint == null) {
      return false;
    }

    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );
    final Offset endOffset = Offset(
      epochToX(endPoint!.epoch),
      quoteToY(endPoint!.quote),
    );

    // Calculate the base vector
    final double deltaX = endOffset.dx - startOffset.dx;
    final double deltaY = endOffset.dy - startOffset.dy;

    // Check each fan line
    for (final double ratio in FibonacciFanHelpers.fibRatios) {
      final Offset fanEndPoint = Offset(
        startOffset.dx + deltaX,
        startOffset.dy + deltaY * ratio,
      );

      // Extend the line to the edge of the screen
      final double screenWidth = drawingContext.contentSize.width;
      final double lineSlope =
          (fanEndPoint.dy - startOffset.dy) / (fanEndPoint.dx - startOffset.dx);
      final Offset extendedEndPoint = Offset(
        screenWidth,
        startOffset.dy + lineSlope * (screenWidth - startOffset.dx),
      );

      // Calculate perpendicular distance from point to line
      final double lineLength = (extendedEndPoint - startOffset).distance;
      if (lineLength < FibfanConstants.minLineLength) {
        continue;
      }

      final double distance =
          ((extendedEndPoint.dy - startOffset.dy) * offset.dx -
                      (extendedEndPoint.dx - startOffset.dx) * offset.dy +
                      extendedEndPoint.dx * startOffset.dy -
                      extendedEndPoint.dy * startOffset.dx)
                  .abs() /
              lineLength;

      // Check if point is within the line segment
      final double dotProduct = (offset.dx - startOffset.dx) *
              (extendedEndPoint.dx - startOffset.dx) +
          (offset.dy - startOffset.dy) * (extendedEndPoint.dy - startOffset.dy);

      final bool isWithinRange =
          dotProduct >= 0 && dotProduct <= lineLength * lineLength;

      if (isWithinRange && distance <= hitTestMargin) {
        return true;
      }
    }

    return false;
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme chartTheme,
    GetDrawingState getDrawingState,
  ) {
    final LineStyle lineStyle = config.lineStyle;
    final LineStyle fillStyle = config.fillStyle;
    final DrawingPaintStyle paintStyle = DrawingPaintStyle();
    final drawingState = getDrawingState(this);

    if (startPoint != null && endPoint != null) {
      final Offset startOffset = Offset(
        epochToX(startPoint!.epoch),
        quoteToY(startPoint!.quote),
      );
      final Offset endOffset = Offset(
        epochToX(endPoint!.epoch),
        quoteToY(endPoint!.quote),
      );

      // Calculate the base vector
      final double deltaX = endOffset.dx - startOffset.dx;
      final double deltaY = endOffset.dy - startOffset.dy;

      // Draw fan lines
      FibonacciFanHelpers.drawFanLines(
          canvas, startOffset, deltaX, deltaY, size, paintStyle, lineStyle,
          fibonacciLevelColors: config.fibonacciLevelColors);

      // Draw labels
      if (drawingState.contains(DrawingToolState.selected)) {
        // Draw filled areas between fan lines
        FibonacciFanHelpers.drawFanFills(
            canvas, startOffset, deltaX, deltaY, size, paintStyle, fillStyle);
        FibonacciFanHelpers.drawFanLabels(
            canvas, startOffset, deltaX, deltaY, size, lineStyle,
            fibonacciLabels: FibonacciFanHelpers.fibonacciLabels,
            fibonacciLevelColors: config.fibonacciLevelColors);
      }

      // Draw endpoints with glowy effect if selected
      if (drawingState.contains(DrawingToolState.selected) ||
          drawingState.contains(DrawingToolState.dragging)) {
        drawPointsFocusedCircle(
          paintStyle,
          lineStyle,
          canvas,
          startOffset,
          FibfanConstants.focusedCircleRadius *
              animationInfo.stateChangePercent,
          FibfanConstants.focusedCircleStroke *
              animationInfo.stateChangePercent,
          endOffset,
        );
      } else if (drawingState.contains(DrawingToolState.hovered)) {
        drawPointsFocusedCircle(
            paintStyle,
            lineStyle,
            canvas,
            startOffset,
            FibfanConstants.focusedCircleRadius,
            FibfanConstants.focusedCircleStroke,
            endOffset);
      }

      // Draw alignment guides when dragging
      if (drawingState.contains(DrawingToolState.dragging) &&
          isDraggingStartPoint != null) {
        if (isDraggingStartPoint!) {
          drawPointAlignmentGuides(canvas, size, startOffset,
              lineColor: config.lineStyle.color);
        } else {
          drawPointAlignmentGuides(canvas, size, endOffset,
              lineColor: config.lineStyle.color);
        }
      } else if (drawingState.contains(DrawingToolState.dragging) &&
          isDraggingStartPoint == null) {
        drawPointAlignmentGuides(canvas, size, startOffset,
            lineColor: config.lineStyle.color);
        drawPointAlignmentGuides(canvas, size, endOffset,
            lineColor: config.lineStyle.color);
      }
    } else if (startPoint != null && _hoverPosition != null) {
      // Preview mode - draw fan from start point to hover position
      final Offset startOffset = Offset(
        epochToX(startPoint!.epoch),
        quoteToY(startPoint!.quote),
      );

      final double deltaX = _hoverPosition!.dx - startOffset.dx;
      final double deltaY = _hoverPosition!.dy - startOffset.dy;

      FibonacciFanHelpers.drawFanLines(
          canvas, startOffset, deltaX, deltaY, size, paintStyle, lineStyle);
      drawPointAlignmentGuides(canvas, size, startOffset,
          lineColor: config.lineStyle.color);
    }
  }

  @override
  void paintOverYAxis(
    ui.Canvas canvas,
    ui.Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme chartTheme,
    GetDrawingState getDrawingState,
  ) {
    if (getDrawingState(this).contains(DrawingToolState.selected)) {
      // Draw value label for start point
      if (startPoint != null) {
        drawValueLabel(
          canvas: canvas,
          quoteToY: quoteToY,
          value: startPoint!.quote,
          pipSize: chartConfig.pipSize,
          animationProgress: animationInfo.stateChangePercent,
          size: size,
          textStyle: config.labelStyle,
          color: config.lineStyle.color,
          backgroundColor: chartTheme.backgroundColor,
        );
      }

      // Draw value label for end point (offset slightly to avoid overlap)
      if (endPoint != null &&
          startPoint != null &&
          endPoint!.quote != startPoint!.quote) {
        drawValueLabel(
          canvas: canvas,
          quoteToY: quoteToY,
          value: endPoint!.quote,
          pipSize: chartConfig.pipSize,
          animationProgress: animationInfo.stateChangePercent,
          size: size,
          textStyle: config.labelStyle,
          color: config.lineStyle.color,
          backgroundColor: chartTheme.backgroundColor,
        );
      }
    }

    paintXAxisLabels(
      canvas,
      size,
      epochToX,
      quoteToY,
      animationInfo,
      chartConfig,
      chartTheme,
      getDrawingState,
    );
  }

  /// Paints epoch labels on the X-axis.
  void paintXAxisLabels(
    ui.Canvas canvas,
    ui.Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
    ChartTheme chartTheme,
    GetDrawingState getDrawingState,
  ) {
    if (getDrawingState(this).contains(DrawingToolState.selected)) {
      // Draw epoch label for start point
      if (startPoint != null) {
        drawEpochLabel(
          canvas: canvas,
          epochToX: epochToX,
          epoch: startPoint!.epoch,
          size: size,
          textStyle: config.labelStyle,
          animationProgress: animationInfo.stateChangePercent,
          color: config.lineStyle.color,
          backgroundColor: chartTheme.backgroundColor,
        );
      }

      // Draw epoch label for end point (only if different from start point to avoid overlap)
      if (endPoint != null &&
          startPoint != null &&
          endPoint!.epoch != startPoint!.epoch) {
        drawEpochLabel(
          canvas: canvas,
          epochToX: epochToX,
          epoch: endPoint!.epoch,
          size: size,
          textStyle: config.labelStyle,
          animationProgress: animationInfo.stateChangePercent,
          color: config.lineStyle.color,
          backgroundColor: chartTheme.backgroundColor,
        );
      }
    }
  }

  @override
  void onDragUpdate(
    DragUpdateDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    if (startPoint == null || endPoint == null) {
      return;
    }

    // Get the drag delta in screen coordinates
    final Offset delta = details.delta;

    // If we're dragging a specific point (start or end point)
    if (isDraggingStartPoint != null) {
      // Get the current point being dragged
      final EdgePoint pointBeingDragged =
          isDraggingStartPoint! ? startPoint! : endPoint!;

      // Get the current screen position of the point
      final Offset currentOffset = Offset(
        epochToX(pointBeingDragged.epoch),
        quoteToY(pointBeingDragged.quote),
      );

      // Apply the delta to get the new screen position
      final Offset newOffset = currentOffset + delta;

      // Convert back to epoch and quote coordinates
      final int newEpoch = epochFromX(newOffset.dx);
      final double newQuote = quoteFromY(newOffset.dy);

      // Create updated point
      final EdgePoint updatedPoint = EdgePoint(
        epoch: newEpoch,
        quote: newQuote,
      );

      // Update the appropriate point
      if (isDraggingStartPoint!) {
        startPoint = updatedPoint;
      } else {
        endPoint = updatedPoint;
      }
    } else {
      // We're dragging the whole fan
      // Convert start and end points to screen coordinates
      final Offset startOffset = Offset(
        epochToX(startPoint!.epoch),
        quoteToY(startPoint!.quote),
      );
      final Offset endOffset = Offset(
        epochToX(endPoint!.epoch),
        quoteToY(endPoint!.quote),
      );

      // Apply the delta to get new screen coordinates
      final Offset newStartOffset = startOffset + delta;
      final Offset newEndOffset = endOffset + delta;

      // Convert back to epoch and quote coordinates
      final int newStartEpoch = epochFromX(newStartOffset.dx);
      final double newStartQuote = quoteFromY(newStartOffset.dy);
      final int newEndEpoch = epochFromX(newEndOffset.dx);
      final double newEndQuote = quoteFromY(newEndOffset.dy);

      // Update the start and end points
      startPoint = EdgePoint(
        epoch: newStartEpoch,
        quote: newStartQuote,
      );
      endPoint = EdgePoint(
        epoch: newEndEpoch,
        quote: newEndQuote,
      );
    }
  }

  @override
  void onDragEnd(
    DragEndDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    // Reset the dragging flag when drag is complete
    isDraggingStartPoint = null;
  }

  @override
  FibfanDrawingToolConfig getUpdatedConfig() =>
      config.copyWith(edgePoints: <EdgePoint>[
        if (startPoint != null) startPoint!,
        if (endPoint != null) endPoint!
      ]);

  @override
  bool isInViewPort(EpochRange epochRange, QuoteRange quoteRange) =>
      (startPoint?.isInEpochRange(
            epochRange.leftEpoch,
            epochRange.rightEpoch,
          ) ??
          true) ||
      (endPoint?.isInEpochRange(
            epochRange.leftEpoch,
            epochRange.rightEpoch,
          ) ??
          true);

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
      getAddingPreviewForDesktopBehaviour(
    InteractiveLayerDesktopBehaviour layerBehaviour,
  ) =>
          FibfanAddingPreviewDesktop(
            interactiveLayerBehaviour: layerBehaviour,
            interactableDrawing: this,
          );

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
      getAddingPreviewForMobileBehaviour(
    InteractiveLayerMobileBehaviour layerBehaviour,
  ) =>
          FibfanAddingPreviewMobile(
            interactiveLayerBehaviour: layerBehaviour,
            interactableDrawing: this,
          );

  @override
  Widget buildDrawingToolBarMenu(UpdateDrawingTool onUpdate) => Row(
        children: <Widget>[
          _buildLineThicknessIcon(),
          const SizedBox(width: FibfanConstants.toolbarSpacing),
          _buildColorPickerIcon(onUpdate)
        ],
      );

  Widget _buildColorPickerIcon(UpdateDrawingTool onUpdate) => SizedBox(
        width: FibfanConstants.toolbarIconSize,
        height: FibfanConstants.toolbarIconSize,
        child: ColorPicker(
          currentColor: config.lineStyle.color,
          onColorChanged: (newColor) => onUpdate(config.copyWith(
            lineStyle: config.lineStyle.copyWith(color: newColor),
            fillStyle: config.fillStyle.copyWith(color: newColor),
          )),
        ),
      );

  Widget _buildLineThicknessIcon() => SizedBox(
        width: FibfanConstants.toolbarIconSize,
        height: FibfanConstants.toolbarIconSize,
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white38,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(FibfanConstants.toolbarBorderRadius),
            ),
          ),
          onPressed: () {
            // update line thickness
          },
          child: Text(
            '${config.lineStyle.thickness.toInt()}px',
            style: const TextStyle(
              fontSize: FibfanConstants.toolbarFontSize,
              color: CoreDesignTokens.coreColorSolidSlate50,
              fontWeight: FontWeight.normal,
              height: FibfanConstants.toolbarTextHeight,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
}
