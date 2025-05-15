import 'dart:ui' as ui;
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/horizontal/horizontal_drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawing_custom_painter.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/drawing_adding_preview.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/horizontal_line/horizontal_line_adding_preview_desktop.dart';
import 'package:deriv_chart/src/models/axis_range.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../../enums/drawing_tool_state.dart';
import '../../helpers/paint_helpers.dart';
import '../../interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import '../../interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import '../drawing_v2.dart';
import '../interactable_drawing.dart';
import 'horizontal_line_adding_preview_mobile.dart';

/// Interactable drawing for horizontal line drawing tool.
class HorizontalLineInteractableDrawing
    extends InteractableDrawing<HorizontalDrawingToolConfig> {
  /// Initializes [HorizontalLineInteractableDrawing].
  HorizontalLineInteractableDrawing({
    required HorizontalDrawingToolConfig config,
    required this.startPoint,
  }) : super(config: config);

  /// Start point of the line.
  EdgePoint? startPoint;

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
    if (startPoint == null) {
      return;
    }

    // Convert start and end points from epoch/quote to screen coordinates
    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );

    // For horizontal line, we only need to check if the drag is near the line
    final double distance = (details.localPosition.dy - startOffset.dy).abs();
    if (distance > hitTestMargin) {
      return;
    }
  }

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    if (startPoint == null) {
      return false;
    }

    // Convert start and end points from epoch/quote to screen coordinates
    final Offset startOffset = Offset(
      epochToX(startPoint!.epoch),
      quoteToY(startPoint!.quote),
    );

    // For horizontal line, we only need to check if the point is near the line's y-coordinate
    final double distance = (offset.dy - startOffset.dy).abs();
    return distance <= hitTestMargin;
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
    final drawingState = getDrawingState(this);

    if (startPoint != null) {
      final Offset startOffset =
          Offset(0, quoteToY(startPoint!.quote)); // Start from left edge
      final Offset endOffset =
          Offset(size.width, quoteToY(startPoint!.quote)); // End at right edge

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
        _drawPointsFocusedCircle(
          paintStyle,
          lineStyle,
          canvas,
          startOffset,
          10 * animationInfo.stateChangePercent,
          3 * animationInfo.stateChangePercent,
          endOffset,
        );
      } else if (drawingState.contains(DrawingToolState.hovered)) {
        _drawPointsFocusedCircle(
            paintStyle, lineStyle, canvas, startOffset, 10, 3, endOffset);
      }

      // Draw alignment guides when dragging
      if (drawingState.contains(DrawingToolState.dragging)) {
        drawPointAlignmentGuides(canvas, size, startOffset);
      }
    } else {
      if (startPoint == null && _hoverPosition != null) {
        // endPoint doesn't exist yet and it means we're creating this line.
        // Drawing preview horizontal line from startPoint's y-coordinate
        final Offset startPosition = Offset(
          0,
          _hoverPosition!.dy,
        );
        final Offset endPosition = Offset(
          size.width,
          _hoverPosition!.dy,
        );
        canvas.drawLine(startPosition, endPosition,
            paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness));
        drawPointAlignmentGuides(canvas, size, startPosition);
      }
    }
  }

  void _drawPointsFocusedCircle(
      DrawingPaintStyle paintStyle,
      LineStyle lineStyle,
      ui.Canvas canvas,
      ui.Offset startOffset,
      double outerCircleRadius,
      double innerCircleRadius,
      ui.Offset endOffset) {
    final normalPaintStyle = paintStyle.glowyCirclePaintStyle(lineStyle.color);
    final glowyPaintStyle =
        paintStyle.glowyCirclePaintStyle(lineStyle.color.withOpacity(0.3));
    canvas
      ..drawCircle(
        startOffset,
        outerCircleRadius,
        glowyPaintStyle,
      )
      ..drawCircle(
        startOffset,
        innerCircleRadius,
        normalPaintStyle,
      )
      ..drawCircle(
        endOffset,
        outerCircleRadius,
        glowyPaintStyle,
      )
      ..drawCircle(
        endOffset,
        innerCircleRadius,
        normalPaintStyle,
      );
  }

  @override
  void onDragUpdate(
    DragUpdateDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    if (startPoint == null) {
      return;
    }

    // Get the drag delta in screen coordinates
    final double deltaY = details.delta.dy;

    // Get the current screen position
    final double currentY = quoteToY(startPoint!.quote);

    // Apply the delta to get the new screen position
    final double newY = currentY + deltaY;

    // Convert back to quote coordinate
    final double newQuote = quoteFromY(newY);

    // Update both points to maintain horizontal line
    startPoint = EdgePoint(
      epoch: startPoint!.epoch,
      quote: newQuote,
    );
  }

  @override
  void onDragEnd(
    DragEndDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    // No special handling needed for drag end
  }

  @override
  HorizontalDrawingToolConfig getUpdatedConfig() => config
      .copyWith(edgePoints: <EdgePoint>[if (startPoint != null) startPoint!]);

  @override
  bool isInViewPort(EpochRange epochRange, QuoteRange quoteRange) =>
      // On X-axis range horizontal line is always visible
      // TODO(NA): consider Y-axis (quoteRange) checking when finding a solution
      // to clear dismiss the existing drawing, if main series is changed and the
      // tool is not supposed to be visible because it's outside of view-port.
      // For now it won't impact that much in terms of performance, since the
      // number tools we allow to add in total is limited to a few.
      true;

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
      getAddingPreviewForDesktopBehaviour(
    InteractiveLayerDesktopBehaviour layerBehaviour,
  ) =>
          HorizontalLineAddingPreviewDesktop(
            interactiveLayerBehaviour: layerBehaviour,
            interactableDrawing: this,
          );

  @override
  DrawingAddingPreview<InteractableDrawing<DrawingToolConfig>>
      getAddingPreviewForMobileBehaviour(
    InteractiveLayerMobileBehaviour layerBehaviour,
  ) =>
          HorizontalLineAddingPreviewMobile(
            interactiveLayerBehaviour: layerBehaviour,
            interactableDrawing: this,
          );
}
