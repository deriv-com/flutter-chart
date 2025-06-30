import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/enums/drawing_tool_state.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

import '../../helpers/types.dart';
import '../drawing_v2.dart';
import 'trend_line_adding_preview.dart';

/// Mobile-specific implementation for trend line adding preview.
///
/// This class handles trend line creation and preview specifically for mobile/touch
/// environments where users interact via touch gestures. It extends
/// [TrendLineAddingPreview] to inherit shared functionality while implementing
/// mobile-specific interaction patterns optimized for touch interfaces.
///
/// ## Mobile Interaction Flow:
/// 1. **Auto-Initialization**: Automatically creates default start and end points
/// 2. **Visual Preview**: Shows dashed preview line with draggable endpoints
/// 3. **Drag Interaction**: Users can drag individual points or the entire line
/// 4. **Tap to Confirm**: Tapping outside the preview confirms the trend line
///
/// ## Key Features:
/// - **Touch-Optimized**: Larger hit areas and visual feedback for touch interaction
/// - **Drag Support**: Full drag functionality for repositioning points and lines
/// - **Visual Feedback**: Focused circles and alignment guides during interactions
/// - **Auto-Positioning**: Intelligent default placement of trend line points
///
/// ## Default Positioning:
/// When initialized, the trend line is automatically positioned with:
/// - Start point at bottom-left quarter of the chart (25% width, 75% height)
/// - End point at top-right quarter of the chart (75% width, 25% height)
/// - This provides a diagonal trend line that users can easily adjust
///
/// ## Drag States:
/// The class tracks different drag states for optimal user experience:
/// - **Individual Point Dragging**: When dragging start or end points specifically
/// - **Whole Line Dragging**: When dragging the line itself to move both points
/// - **Visual Feedback**: Different visual effects based on what's being dragged
///
/// ## Usage:
/// This class is typically instantiated by the drawing system when a user
/// selects the trend line tool on a mobile platform:
///
/// ```dart
/// final preview = TrendLineAddingPreviewMobile(
///   interactiveLayerBehaviour: mobileBehaviour,
///   interactableDrawing: trendLineDrawing,
/// );
/// ```
///
/// ## Performance Considerations:
/// - Efficient hit testing for touch interactions
/// - Smooth drag animations with proper state management
/// - Optimized rendering during drag operations
/// - Minimal redraws during interaction states
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
  ) {}

  @override
  void paintOverYAxis(
      Canvas canvas,
      Size size,
      EpochToX epochToX,
      QuoteToY quoteToY,
      EpochFromX? epochFromX,
      QuoteFromY? quoteFromY,
      AnimationInfo animationInfo,
      ChartConfig chartConfig,
      ChartTheme chartTheme,
      GetDrawingState getDrawingState) {
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
        drawAlignmentGuidesWithLabels(
          canvas,
          size,
          startOffset,
          epochToX,
          quoteToY,
          chartConfig,
          chartTheme,
          interactiveLayerBehaviour.interactiveLayer.epochFromX,
          interactiveLayerBehaviour.interactiveLayer.quoteFromY,
        );
      }

      // Draw end point
      drawStyledPointOffset(
          endOffset, epochToX, quoteToY, canvas, paintStyle, lineStyle);

      // Draw focused effect and alignment guides for end point if dragging
      if (interactableDrawing.isDraggingStartPoint != null &&
          !interactableDrawing.isDraggingStartPoint!) {
        drawStyledFocusedCircle(paintStyle, lineStyle, canvas, endOffset,
            animationInfo.stateChangePercent);
        drawAlignmentGuidesWithLabels(
          canvas,
          size,
          endOffset,
          epochToX,
          quoteToY,
          chartConfig,
          chartTheme,
          interactiveLayerBehaviour.interactiveLayer.epochFromX,
          interactiveLayerBehaviour.interactiveLayer.quoteFromY,
        );
      }

      // Draw alignment guides with labels for both points when dragging the entire line
      if (interactableDrawing.isDraggingStartPoint == null &&
          getDrawingState(this).contains(DrawingToolState.dragging)) {
        drawAlignmentGuidesWithLabels(
          canvas,
          size,
          startOffset,
          epochToX,
          quoteToY,
          chartConfig,
          chartTheme,
          interactiveLayerBehaviour.interactiveLayer.epochFromX,
          interactiveLayerBehaviour.interactiveLayer.quoteFromY,
        );
        drawAlignmentGuidesWithLabels(
          canvas,
          size,
          endOffset,
          epochToX,
          quoteToY,
          chartConfig,
          chartTheme,
          interactiveLayerBehaviour.interactiveLayer.epochFromX,
          interactiveLayerBehaviour.interactiveLayer.quoteFromY,
        );
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
    interactableDrawing.onDragStart(
        details, epochFromX, quoteFromY, epochToX, quoteToY);
  }

  @override
  void onDragEnd(DragEndDetails details, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
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
