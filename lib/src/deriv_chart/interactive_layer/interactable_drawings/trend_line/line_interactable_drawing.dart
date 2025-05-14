import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/line/line_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/extensions/extensions.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/enums/drawing_tool_state.dart';
import 'package:deriv_chart/src/models/axis_range.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/widgets.dart';

import '../../helpers/paint_helpers.dart';
import '../../interactable_drawing_custom_painter.dart';
import '../../interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import '../../interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import '../drawing_adding_preview.dart';
import '../drawing_v2.dart';
import '../interactable_drawing.dart';
import 'trend_line_adding_preview_desktop.dart';
import 'trend_line_adding_preview_mobile.dart';

/// Interactable drawing for line drawing tool.
class LineInteractableDrawing
    extends InteractableDrawing<LineDrawingToolConfig> {
  /// Initializes [LineInteractableDrawing].
  LineInteractableDrawing({
    required LineDrawingToolConfig config,
    required this.startPoint,
    required this.endPoint,
  }) : super(config: config);

  /// Start point of the line.
  EdgePoint? startPoint;

  /// End point of the line.
  EdgePoint? endPoint;

  // Tracks which point is being dragged, if any
  // null: dragging the whole line
  // true: dragging the start point
  // false: dragging the end point
  bool? _isDraggingStartPoint;

  @override
  void onDragStart(
    DragStartDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    if (startPoint != null && endPoint == null) {
      final Offset startOffset = Offset(
        epochToX(startPoint!.epoch),
        quoteToY(startPoint!.quote),
      );

      // Check if the drag is starting on the start point
      if ((details.localPosition - startOffset).distance <= hitTestMargin) {
        _isDraggingStartPoint = true;
        return;
      }
    }

    if (startPoint == null || endPoint == null) {
      return;
    }

    // Reset the dragging flag
    _isDraggingStartPoint = null;

    // Convert start and end points from epoch/quote to screen coordinates
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
      _isDraggingStartPoint = true;
      return;
    }

    // If the drag is starting on the end point
    if (endDistance <= hitTestMargin) {
      _isDraggingStartPoint = false;
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
    GetDrawingState getDrawingState,
  ) {
    final LineStyle lineStyle = config.lineStyle;
    final DrawingPaintStyle paintStyle = DrawingPaintStyle();
    // Check if this drawing is selected

    final drawingState = getDrawingState(this);
    if (startPoint != null && endPoint != null) {
      final Offset startOffset =
          Offset(epochToX(startPoint!.epoch), quoteToY(startPoint!.quote));
      final Offset endOffset =
          Offset(epochToX(endPoint!.epoch), quoteToY(endPoint!.quote));

      // Use glowy paint style if selected, otherwise use normal paint style
      final Paint paint = drawingState.contains(DrawingToolState.selected) ||
              drawingState.contains(DrawingToolState.dragging)
          ? paintStyle.linePaintStyle(
              lineStyle.color, 1 + 1 * animationInfo.stateChangePercent)
          : paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness);

      canvas.drawLine(startOffset, endOffset, paint);

      // Draw endpoints with glowy effect if selected
      if (drawingState.contains(DrawingToolState.selected) ||
          drawingState.contains(DrawingToolState.dragging)) {
        drawPointsFocusedCircle(
          paintStyle,
          lineStyle,
          canvas,
          startOffset,
          10 * animationInfo.stateChangePercent,
          3 * animationInfo.stateChangePercent,
          endOffset,
        );
      } else if (drawingState.contains(DrawingToolState.hovered)) {
        drawPointsFocusedCircle(
            paintStyle, lineStyle, canvas, startOffset, 10, 3, endOffset);
      }

      // Draw alignment guides when dragging
      if (drawingState.contains(DrawingToolState.dragging)) {
        _drawAlignmentGuides(canvas, size, startOffset, endOffset, paintStyle);
      }
    } else if (drawingState.contains(DrawingToolState.adding)) {
      if (startPoint != null) {
        drawPoint(
            startPoint!, epochToX, quoteToY, canvas, paintStyle, lineStyle);
        drawPointAlignmentGuides(canvas, size,
            Offset(epochToX(startPoint!.epoch), quoteToY(startPoint!.quote)));
      }

      if (endPoint != null) {
        drawPoint(endPoint!, epochToX, quoteToY, canvas, paintStyle, lineStyle);
      }
    }
  }

  /// Draws alignment guides (horizontal and vertical lines) from the points
  void _drawAlignmentGuides(Canvas canvas, Size size, Offset startOffset,
      Offset endOffset, DrawingPaintStyle paintStyle) {
    // Draw alignment guides for both start and end points
    drawPointAlignmentGuides(canvas, size, startOffset);
    drawPointAlignmentGuides(canvas, size, endOffset);
  }

  @override
  void onDragUpdate(
    DragUpdateDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    if (startPoint != null &&
        endPoint == null &&
        (Offset(
                      epochToX(startPoint!.epoch),
                      quoteToY(startPoint!.quote),
                    ) -
                    details.localPosition)
                .distance <
            hitTestMargin) {
      // If we're dragging the start point, we need to update its position
      final Offset startOffset = Offset(
        epochToX(startPoint!.epoch),
        quoteToY(startPoint!.quote),
      );

      // Apply the delta to get the new screen position
      final Offset newOffset = startOffset + details.delta;

      // Convert back to epoch and quote coordinates
      final int newEpoch = epochFromX(newOffset.dx);
      final double newQuote = quoteFromY(newOffset.dy);

      // Update the start point
      startPoint = EdgePoint(
        epoch: newEpoch,
        quote: newQuote,
      );
    }
    if (startPoint == null || endPoint == null) {
      return;
    }

    // Get the drag delta in screen coordinates
    final Offset delta = details.delta;

    // If we're dragging a specific point (start or end point)
    if (_isDraggingStartPoint != null) {
      // Get the current point being dragged
      final EdgePoint pointBeingDragged =
          _isDraggingStartPoint! ? startPoint! : endPoint!;

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
      if (_isDraggingStartPoint!) {
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
    _isDraggingStartPoint = null;
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
  ) =>
      LineAddingPreviewMobile(
        interactiveLayerBehaviour: layerBehaviour,
        interactableDrawing: this,
      );

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
      getAddingPreviewForDesktopBehaviour(
    InteractiveLayerDesktopBehaviour layerBehaviour,
  ) =>
          LineAddingPreviewDesktop(
            interactiveLayerBehaviour: layerBehaviour,
            interactableDrawing: this,
          );
}
