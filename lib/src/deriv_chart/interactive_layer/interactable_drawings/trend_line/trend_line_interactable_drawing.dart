import 'dart:ui' as ui;

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/callbacks.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/line/line_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/extensions/extensions.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/enums/drawing_tool_state.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/widgets/color_picker.dart';
import 'package:deriv_chart/src/models/axis_range.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/design_tokens/core_design_tokens.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../../helpers/paint_helpers.dart';
import '../../helpers/types.dart';
import '../../interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import '../../interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';
import '../drawing_adding_preview.dart';
import '../drawing_v2.dart';
import '../interactable_drawing.dart';
import 'trend_line_adding_preview_desktop.dart';
import 'trend_line_adding_preview_mobile.dart';

/// Interactable drawing implementation for trend line drawing tool.
///
/// This class represents a complete trend line drawing that can be interacted with
/// on the chart. It handles all aspects of trend line behavior including rendering,
/// hit testing, drag interactions, and state management. The class extends
/// [InteractableDrawing] to provide trend line-specific functionality.
///
/// ## Core Functionality:
/// - **Rendering**: Draws the trend line with points, glow effects, and labels
/// - **Hit Testing**: Determines if user interactions hit the line or its endpoints
/// - **Drag Interactions**: Supports dragging individual points or the entire line
/// - **State Management**: Tracks selection, hover, and drag states
/// - **Configuration**: Manages line styling, colors, and thickness
///
/// ## Interaction States:
/// The trend line supports multiple interaction states:
/// - **Normal**: Basic line rendering without special effects
/// - **Hovered**: Subtle visual feedback when mouse hovers over the line
/// - **Selected**: Enhanced visibility with glow effects and control points
/// - **Dragging**: Real-time updates during drag operations with alignment guides
///
/// ## Drag Behavior:
/// The class supports three types of drag operations:
/// - **Start Point Drag**: When [isDraggingStartPoint] is `true`
/// - **End Point Drag**: When [isDraggingStartPoint] is `false`
/// - **Whole Line Drag**: When [isDraggingStartPoint] is `null`
///
/// ## Visual Elements:
/// When active, the trend line displays:
/// - Main line connecting start and end points
/// - Control points at both endpoints (when selected/hovered)
/// - Neon glow effect around the line (when selected)
/// - Focused circles around dragged points
/// - Alignment guides during drag operations
/// - Value and epoch labels on chart axes
///
/// ## Platform Support:
/// The class works with both desktop and mobile platforms through different
/// preview implementations:
/// - [TrendLineAddingPreviewDesktop] for mouse-based interactions
/// - [TrendLineAddingPreviewMobile] for touch-based interactions
///
/// ## Usage Example:
/// ```dart
/// final trendLine = TrendLineInteractableDrawing(
///   config: LineDrawingToolConfig(
///     lineStyle: LineStyle(color: Colors.blue, thickness: 2.0),
///     labelStyle: TextStyle(color: Colors.blue),
///   ),
///   startPoint: EdgePoint(epoch: 1000, quote: 1.2345),
///   endPoint: EdgePoint(epoch: 2000, quote: 1.2400),
///   drawingContext: context,
///   getDrawingState: (drawing) => {DrawingToolState.normal},
/// );
/// ```
///
/// ## Performance Considerations:
/// - Efficient hit testing using mathematical line-to-point distance calculations
/// - Optimized rendering with early returns for off-screen elements
/// - Smooth drag operations with delta-based coordinate updates
/// - Minimal repaints during state changes
class TrendLineInteractableDrawing
    extends InteractableDrawing<LineDrawingToolConfig> {
  /// Initializes [TrendLineInteractableDrawing].
  TrendLineInteractableDrawing({
    required LineDrawingToolConfig config,
    required this.startPoint,
    required this.endPoint,
    required super.drawingContext,
    required super.getDrawingState,
  }) : super(drawingConfig: config);

  // TODO(Ramin): make it non-nullable.
  /// Start point of the line.
  EdgePoint? startPoint;

  /// End point of the line.
  EdgePoint? endPoint;

  /// Tracks which point is being dragged, if any
  ///
  /// [null]: dragging the whole line.
  ///
  /// [true]: dragging the start point.
  ///
  /// [false]: dragging the end point.
  bool? isDraggingStartPoint;

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

    // Check if the drag is starting on the start point
    if ((details.localPosition - startOffset).distance <= hitTestMargin) {
      isDraggingStartPoint = true;
      return;
    }

    // Reset the dragging flag
    isDraggingStartPoint = null;

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

    // If we reach here, the drag is on the line itself, not on a specific point
    // _isDraggingStartPoint remains null, indicating we're dragging the whole line
  }

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    if (startPoint != null) {
      final startOffset = Offset(
        epochToX(startPoint!.epoch),
        quoteToY(startPoint!.quote),
      );

      if ((offset - startOffset).distance <= hitTestMargin) {
        return true;
      }
    }
    if (startPoint == null || endPoint == null) {
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
    // Use a slightly larger margin for the endpoints to make them easier to hit
    final double startDistance = (offset - startOffset).distance;
    final double endDistance = (offset - endOffset).distance;

    if (startDistance <= hitTestMargin || endDistance <= hitTestMargin) {
      return true;
    }

    // Calculate line length
    final double lineLength = (endOffset - startOffset).distance;

    // If line length is too small, treat it as a point
    if (lineLength < 1) {
      return (offset - startOffset).distance <= hitTestMargin;
    }

    // Calculate perpendicular distance from point to line
    // Formula: |((y2-y1)x - (x2-x1)y + x2y1 - y2x1)| / sqrt((y2-y1)² + (x2-x1)²)
    final double distance = ((endOffset.dy - startOffset.dy) * offset.dx -
                (endOffset.dx - startOffset.dx) * offset.dy +
                endOffset.dx * startOffset.dy -
                endOffset.dy * startOffset.dx)
            .abs() /
        lineLength;

    // Check if point is within the line segment (not just the infinite line)
    final double dotProduct =
        (offset.dx - startOffset.dx) * (endOffset.dx - startOffset.dx) +
            (offset.dy - startOffset.dy) * (endOffset.dy - startOffset.dy);

    final bool isWithinRange =
        dotProduct >= 0 && dotProduct <= lineLength * lineLength;

    final result = isWithinRange && distance <= hitTestMargin;
    return result;
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
    final DrawingPaintStyle paintStyle = DrawingPaintStyle();
    final drawingState = getDrawingState(this);

    if (startPoint != null && endPoint != null) {
      final Offset startOffset =
          Offset(epochToX(startPoint!.epoch), quoteToY(startPoint!.quote));
      final Offset endOffset =
          Offset(epochToX(endPoint!.epoch), quoteToY(endPoint!.quote));

      // Draw neon glow effect first if selected but not dragging individual points
      if (drawingState.contains(DrawingToolState.selected) &&
          !(drawingState.contains(DrawingToolState.dragging) &&
              isDraggingStartPoint != null)) {
        final neonPaint = Paint()
          ..color = config.lineStyle.color.withOpacity(0.4)
          ..strokeWidth = 8 * animationInfo.stateChangePercent
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawLine(startOffset, endOffset, neonPaint);
      }

      // Draw the main line on top to keep it crisp
      final Paint paint =
          paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness);
      canvas.drawLine(startOffset, endOffset, paint);

      // Only draw points when there's an active interaction (selected, hovered, or dragging)
      if (drawingState.contains(DrawingToolState.selected) ||
          drawingState.contains(DrawingToolState.hovered) ||
          drawingState.contains(DrawingToolState.dragging)) {
        // Draw both points as normal circles first
        drawPointOffset(
            startOffset, epochToX, quoteToY, canvas, paintStyle, lineStyle,
            radius: 4);
        drawPointOffset(
            endOffset, epochToX, quoteToY, canvas, paintStyle, lineStyle,
            radius: 4);

        // Then add glowy effect on top based on state
        if (drawingState.contains(DrawingToolState.dragging) &&
            isDraggingStartPoint != null) {
          // When dragging, only show glow on the point being dragged
          final Offset draggedPointOffset =
              isDraggingStartPoint! ? startOffset : endOffset;
          drawFocusedCircle(
            paintStyle,
            lineStyle,
            canvas,
            draggedPointOffset,
            10 * animationInfo.stateChangePercent,
            3 * animationInfo.stateChangePercent,
          );
        } else if (drawingState.contains(DrawingToolState.dragging) &&
            isDraggingStartPoint == null) {
          // When dragging the whole line, show glow on both points
          drawPointsFocusedCircle(
            paintStyle,
            lineStyle,
            canvas,
            startOffset,
            10 * animationInfo.stateChangePercent,
            3 * animationInfo.stateChangePercent,
            endOffset,
          );
        } else if (drawingState.contains(DrawingToolState.selected) ||
            drawingState.contains(DrawingToolState.hovered)) {
          // When not dragging, show glow on both points
          drawPointsFocusedCircle(
            paintStyle,
            lineStyle,
            canvas,
            startOffset,
            drawingState.contains(DrawingToolState.selected)
                ? 10 * animationInfo.stateChangePercent
                : 10,
            drawingState.contains(DrawingToolState.selected)
                ? 3 * animationInfo.stateChangePercent
                : 3,
            endOffset,
          );
        }
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
    }
  }

  @override
  void paintOverYAxis(
    ui.Canvas canvas,
    ui.Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    epochFromX,
    quoteFromY,
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
    // Paint X-axis labels when selected
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

  /// Paints epoch labels on the X-axis when the trend line is selected.
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
      // We're dragging the whole line
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
  LineDrawingToolConfig getUpdatedConfig() =>
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
  DrawingAddingPreview getAddingPreviewForMobileBehaviour(
    InteractiveLayerMobileBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) =>
      TrendLineAddingPreviewMobile(
        interactiveLayerBehaviour: layerBehaviour,
        interactableDrawing: this,
        onAddingStateChange: onAddingStateChange,
      );

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
      getAddingPreviewForDesktopBehaviour(
    InteractiveLayerDesktopBehaviour layerBehaviour,
    Function(AddingStateInfo) onAddingStateChange,
  ) =>
          TrendLineAddingPreviewDesktop(
            interactiveLayerBehaviour: layerBehaviour,
            interactableDrawing: this,
            onAddingStateChange: onAddingStateChange,
          );

  @override
  Widget buildDrawingToolBarMenu(UpdateDrawingTool onUpdate) => Row(
        children: <Widget>[
          _buildLineThicknessIcon(),
          const SizedBox(width: 4),
          _buildColorPickerIcon(onUpdate)
        ],
      );

  Widget _buildColorPickerIcon(UpdateDrawingTool onUpdate) => SizedBox(
        width: 32,
        height: 32,
        child: ColorPicker(
          currentColor: config.lineStyle.color,
          onColorChanged: (newColor) => onUpdate(config.copyWith(
            lineStyle: config.lineStyle.copyWith(color: newColor),
            labelStyle: config.labelStyle.copyWith(color: newColor),
          )),
        ),
      );

  Widget _buildLineThicknessIcon() => SizedBox(
        width: 32,
        height: 32,
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white38,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onPressed: () {
            // TODO(Jim): Implement line thickness selection functionality
            // This will allow users to change the thickness of the trend line
          },
          child: Text(
            '${config.lineStyle.thickness.toInt()}px',
            style: const TextStyle(
              fontSize: 14,
              color: CoreDesignTokens.coreColorSolidSlate50,
              fontWeight: FontWeight.normal,
              height: 2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
}
