import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/enums/drawing_tool_state.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/enums/state_change_direction.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/widgets.dart';

import '../../helpers/paint_helpers.dart';
import '../../interactable_drawing_custom_painter.dart';
import '../drawing_adding_preview.dart';
import '../drawing_v2.dart';
import 'trend_line_interactable_drawing.dart';

/// A class to show a preview and handle adding a [TrendLineInteractableDrawing]
/// to the chart. This is for when we're on [InteractiveLayerMobileBehaviour]
class TrendLineAddingPreviewMobile
    extends DrawingAddingPreview<TrendLineInteractableDrawing> {
  /// Initializes [TrendLineInteractableDrawing].
  TrendLineAddingPreviewMobile({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
  }) {
    if (interactableDrawing.startPoint == null) {
      final interactiveLayer = interactiveLayerBehaviour.interactiveLayer;
      final Offset centerOffset = _getCenterOfScreen();

      interactableDrawing.startPoint = EdgePoint(
        epoch: interactiveLayer.epochFromX(centerOffset.dx),
        quote: interactiveLayer.quoteFromY(centerOffset.dy),
      );
    }
  }

  /// If `true` it indicates that the position of the first point is confirmed
  /// by the user and the second point should be spawned and animated to the
  /// center of the screen. Once the animation is done, it will become `false`.
  bool _animatingSecondPoint = false;

  Offset _getCenterOfScreen() {
    final interactiveLayer = interactiveLayerBehaviour.interactiveLayer;
    final Size? layerSize = interactiveLayer.layerSize;

    final double centerX = layerSize != null ? layerSize.width / 2 : 0;
    final double centerY = layerSize != null ? layerSize.height / 2 : 0;

    return Offset(centerX, centerY);
  }

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    final EdgePoint? startPoint = interactableDrawing.startPoint;
    final EdgePoint? endPoint = interactableDrawing.endPoint;

    if (startPoint != null && endPoint == null) {
      final startOffset = Offset(
        epochToX(startPoint.epoch),
        quoteToY(startPoint.quote),
      );

      if ((offset - startOffset).distance <= hitTestMargin) {
        return true;
      }
    } else if (endPoint != null) {
      final endOffset = Offset(
        epochToX(endPoint.epoch),
        quoteToY(endPoint.quote),
      );

      if ((offset - endOffset).distance <= hitTestMargin) {
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
    GetDrawingState getDrawingState,
  ) {
    final LineStyle lineStyle = interactableDrawing.config.lineStyle;
    final DrawingPaintStyle paintStyle = DrawingPaintStyle();

    final EdgePoint? startPoint = interactableDrawing.startPoint;
    final EdgePoint? endPoint = interactableDrawing.endPoint;
    final Set<DrawingToolState> drawingState = getDrawingState(this);

    if (startPoint != null && endPoint == null) {
      // Start point is spawned at the chart, user can move it, we should show
      // alignment cross-hair on start point.
      drawPoint(
        startPoint,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        lineStyle,
        radius: 5 + animationInfo.stateChangePercent * 3,
      );
      drawPointAlignmentGuides(canvas, size,
          Offset(epochToX(startPoint.epoch), quoteToY(startPoint.quote)));
    } else if (startPoint != null && endPoint != null) {
      // End point is also spawned at the chart, user can move it, we should
      // show alignment cross-hair on end point.

      final startOffset =
          Offset(epochToX(startPoint.epoch), quoteToY(startPoint.quote));
      final targetEndOffset =
          Offset(epochToX(endPoint.epoch), quoteToY(endPoint.quote));

      late final Offset endOffset;

      if (_animatingSecondPoint) {
        endOffset = Offset.lerp(
          startOffset,
          targetEndOffset,
          animationInfo.stateChangePercent,
        )!;
      } else {
        endOffset = targetEndOffset;
      }

      drawPointOffset(
        endOffset,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        lineStyle,
        radius: 5 + animationInfo.stateChangePercent * 3,
      );

      drawPointAlignmentGuides(canvas, size, endOffset);

      // Use glowy paint style if selected, otherwise use normal paint style
      final Paint paint = drawingState.contains(DrawingToolState.selected) ||
              drawingState.contains(DrawingToolState.dragging)
          ? paintStyle.linePaintStyle(
              lineStyle.color, 1 + 1 * animationInfo.stateChangePercent)
          : paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness);
      canvas.drawLine(startOffset, endOffset, paint);
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
    final EdgePoint? startPoint = interactableDrawing.startPoint;
    final EdgePoint? endPoint = interactableDrawing.endPoint;

    if (startPoint == null) {
      interactableDrawing.startPoint = EdgePoint(
        epoch: epochFromX(details.localPosition.dx),
        quote: quoteFromY(details.localPosition.dy),
      );
    } else if (endPoint == null) {
      _animatingSecondPoint = true;
      interactiveLayerBehaviour
          .updateStateTo(
            interactiveLayerBehaviour.currentState,
            StateChangeAnimationDirection.forward,
            waitForAnimation: true,
          )
          .then(
            (_) => _animatingSecondPoint = false,
          );

      final Offset centerOffset = _getCenterOfScreen();

      interactableDrawing.endPoint = EdgePoint(
        epoch: epochFromX(centerOffset.dx),
        quote: quoteFromY(centerOffset.dy),
      );
    } else {
      onDone();
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
    final EdgePoint? startPoint = interactableDrawing.startPoint;
    final EdgePoint? endPoint = interactableDrawing.endPoint;

    if (startPoint != null && endPoint == null) {
      // If we're dragging the start point, we need to update its position
      final Offset startOffset =
          Offset(epochToX(startPoint.epoch), quoteToY(startPoint.quote));

      // Apply the delta to get the new screen position
      final Offset newOffset = startOffset + details.delta;

      // Convert back to epoch and quote coordinates
      final int newEpoch = epochFromX(newOffset.dx);
      final double newQuote = quoteFromY(newOffset.dy);

      // Update the start point
      interactableDrawing.startPoint =
          EdgePoint(epoch: newEpoch, quote: newQuote);
    } else if (endPoint != null) {
      // If we're dragging the start point, we need to update its position
      final Offset endOffset =
          Offset(epochToX(endPoint.epoch), quoteToY(endPoint.quote));

      // Apply the delta to get the new screen position
      final Offset newOffset = endOffset + details.delta;

      // Convert back to epoch and quote coordinates
      final int newEpoch = epochFromX(newOffset.dx);
      final double newQuote = quoteFromY(newOffset.dy);

      // Update the start point
      interactableDrawing.endPoint =
          EdgePoint(epoch: newEpoch, quote: newQuote);
    }
  }

  @override
  String get id => 'line-adding-preview-mobile';
}
