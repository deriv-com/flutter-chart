import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/enums/drawing_tool_state.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/enums/state_change_direction.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../../helpers/paint_helpers.dart';
import '../../helpers/types.dart';
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
    final LineStyle lineStyle = interactableDrawing.config.lineStyle;
    final DrawingPaintStyle paintStyle = DrawingPaintStyle();

    final EdgePoint? startPoint = interactableDrawing.startPoint;
    final EdgePoint? endPoint = interactableDrawing.endPoint;
    final Set<DrawingToolState> drawingState = getDrawingState(this);

    if (startPoint != null && endPoint != null) {
      // End point is also spawned at the chart, user can move it, we should
      // show alignment cross-hair on end point.

      final startOffset =
          Offset(epochToX(startPoint.epoch), quoteToY(startPoint.quote));
      final targetEndOffset =
          Offset(epochToX(endPoint.epoch), quoteToY(endPoint.quote));

      late final Offset endOffset;

      endOffset = targetEndOffset;

      drawPointOffset(
        startOffset,
        epochToX,
        quoteToY,
        canvas,
        paintStyle,
        lineStyle,
      );
      if (interactableDrawing.isDraggingStartPoint != null &&
          interactableDrawing.isDraggingStartPoint!) {
        drawFocusedCircle(
          paintStyle,
          lineStyle,
          canvas,
          startOffset,
          4 + 8 * animationInfo.stateChangePercent,
          4,
        );

        drawPointAlignmentGuides(canvas, size, startOffset);
      }

      drawPointOffset(
          endOffset, epochToX, quoteToY, canvas, paintStyle, lineStyle,
          radius: 4);

      if (interactableDrawing.isDraggingStartPoint != null &&
          !interactableDrawing.isDraggingStartPoint!) {
        drawFocusedCircle(
          paintStyle,
          lineStyle,
          canvas,
          endOffset,
          4 + 8 * animationInfo.stateChangePercent,
          4,
        );

        drawPointAlignmentGuides(canvas, size, endOffset);
      }

      // Use glowy paint style if selected, otherwise use normal paint style
      final Paint paint = drawingState.contains(DrawingToolState.selected) ||
              drawingState.contains(DrawingToolState.dragging)
          ? paintStyle.linePaintStyle(
              lineStyle.color, 1 + 1 * animationInfo.stateChangePercent)
          : paintStyle.linePaintStyle(lineStyle.color, lineStyle.thickness);

      final Path linePath = _createLinePath(startOffset, endOffset);

      canvas.drawPath(
        dashPath(linePath, dashArray: CircularIntervalList([4, 4])),
        Paint()
          ..color = paint.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = paint.strokeWidth,
      );
    }
  }

  Path _createLinePath(Offset start, Offset end) => Path()
    ..moveTo(start.dx, start.dy)
    ..lineTo(end.dx, end.dy);

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
