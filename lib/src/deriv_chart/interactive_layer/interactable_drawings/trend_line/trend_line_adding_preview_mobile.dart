import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/enums/drawing_tool_state.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/enums/state_change_direction.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

import '../../helpers/paint_helpers.dart';
import '../../helpers/types.dart';
import '../drawing_v2.dart';
import 'trend_line_adding_preview.dart';

/// A class to show a preview and handle adding a [TrendLineInteractableDrawing]
/// to the chart. This is for when we're on [InteractiveLayerMobileBehaviour]
class TrendLineAddingPreviewMobile extends TrendLineAddingPreview {
  /// Initializes [TrendLineInteractableDrawing].
  TrendLineAddingPreviewMobile({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
  }) {
    if (interactableDrawing.startPoint == null) {
      final interactiveLayer = interactiveLayerBehaviour.interactiveLayer;
      final Size size = interactiveLayer.drawingContext.fullSize;

      final bottomLeftCenter = Offset(size.width / 4, size.height * 3 / 4);
      final topRightCenter = Offset(size.width * 3 / 4, size.height / 4);

      interactableDrawing
        ..startPoint = EdgePoint(
          epoch: interactiveLayer.epochFromX(bottomLeftCenter.dx),
          quote: interactiveLayer.quoteFromY(bottomLeftCenter.dy),
        )
        ..endPoint = EdgePoint(
          epoch: interactiveLayer.epochFromX(topRightCenter.dx),
          quote: interactiveLayer.quoteFromY(topRightCenter.dy),
        );
    }
  }

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) =>
      interactableDrawing.hitTest(offset, epochToX, quoteToY);

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
    final (paintStyle, lineStyle) = getStyles();
    final EdgePoint? startPoint = interactableDrawing.startPoint;
    final EdgePoint? endPoint = interactableDrawing.endPoint;

    if (startPoint != null && endPoint != null) {
      final startOffset = edgePointToOffset(startPoint, epochToX, quoteToY);
      final endOffset = edgePointToOffset(endPoint, epochToX, quoteToY);

      // Draw start point
      drawStyledPointOffset(
          startOffset, epochToX, quoteToY, canvas, paintStyle, lineStyle);

      // Draw focused effect and alignment guides for start point if dragging
      if (interactableDrawing.isDraggingStartPoint != null &&
          interactableDrawing.isDraggingStartPoint!) {
        drawStyledFocusedCircle(paintStyle, lineStyle, canvas, startOffset,
            animationInfo.stateChangePercent);
        drawPointAlignmentGuides(canvas, size, startOffset);
      }

      // Draw end point
      drawStyledPointOffset(
          endOffset, epochToX, quoteToY, canvas, paintStyle, lineStyle);

      // Draw focused effect and alignment guides for end point if dragging
      if (interactableDrawing.isDraggingStartPoint != null &&
          !interactableDrawing.isDraggingStartPoint!) {
        drawStyledFocusedCircle(paintStyle, lineStyle, canvas, endOffset,
            animationInfo.stateChangePercent);
        drawPointAlignmentGuides(canvas, size, endOffset);
      }

      // Draw the preview line with dashed style
      drawPreviewLine(canvas, startOffset, endOffset, paintStyle, lineStyle,
          isDashed: true);
    }
  }

  @override
  void onCreateTap(
    TapUpDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
    VoidCallback onDone,
  ) {
    if (!interactableDrawing.hitTest(
      details.localPosition,
      epochToX,
      quoteToY,
    )) {
      // Tap is outside the drawing preview. means adding is confirmed.
      onDone();
    }
  }

  @override
  void onDragStart(DragStartDetails details, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    interactiveLayerBehaviour.updateStateTo(
      interactiveLayerBehaviour.currentState,
      StateChangeAnimationDirection.forward,
    );

    interactableDrawing.onDragStart(
        details, epochFromX, quoteFromY, epochToX, quoteToY);
  }

  @override
  void onDragEnd(DragEndDetails details, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    interactiveLayerBehaviour.updateStateTo(
      interactiveLayerBehaviour.currentState,
      StateChangeAnimationDirection.backward,
    );

    interactableDrawing.onDragEnd(
      details,
      epochFromX,
      quoteFromY,
      epochToX,
      quoteToY,
    );
  }

  @override
  void onDragUpdate(
    DragUpdateDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) =>
      interactableDrawing.onDragUpdate(
        details,
        epochFromX,
        quoteFromY,
        epochToX,
        quoteToY,
      );

  @override
  bool shouldRepaint(Set<DrawingToolState> drawingState, DrawingV2 oldDrawing) {
    return true;
  }

  @override
  String get id => 'trend-line-adding-preview-mobile';
}
