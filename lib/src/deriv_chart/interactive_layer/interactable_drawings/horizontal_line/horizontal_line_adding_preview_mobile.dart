import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/drawing_v2.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/widgets.dart';
import '../../enums/drawing_tool_state.dart';
import '../../helpers/types.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';
import '../drawing_adding_preview.dart';
import 'horizontal_line_interactable_drawing.dart';

/// A class to show a preview and handle adding a
/// [HorizontalLineInteractableDrawing] to the chart. It's for when we're on
/// [InteractiveLayerMobileBehaviour].
///
/// This mobile preview provides immediate focus mode by:
/// - Automatically placing the line at the center of the chart
/// - Immediately completing the adding process for instant focus mode
/// - Delegating visual rendering to the main drawing for consistency
/// - Providing full functionality (drag, neon effects, proper labeling)
class HorizontalLineAddingPreviewMobile
    extends DrawingAddingPreview<HorizontalLineInteractableDrawing> {
  /// Initializes [HorizontalLineInteractableDrawing].
  HorizontalLineAddingPreviewMobile({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
    required super.onAddingStateChange,
  }) {
    if (interactableDrawing.startPoint == null) {
      final interactiveLayer = interactiveLayerBehaviour.interactiveLayer;
      final Size? layerSize = interactiveLayer.drawingContext.fullSize;

      final double centerX = layerSize != null ? layerSize.width / 2 : 0;
      final double centerY = layerSize != null ? layerSize.height / 2 : 0;

      interactableDrawing.startPoint = EdgePoint(
        epoch: interactiveLayer.epochFromX(centerX),
        quote: interactiveLayer.quoteFromY(centerY),
      );

      // Use a post-frame callback to ensure the startPoint is fully set before transitioning
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onAddingStateChange(AddingStateInfo(1, 1));
      });
    }
  }

  @override
  bool hitTest(Offset offset, EpochToX epochToX, QuoteToY quoteToY) {
    if (interactableDrawing.startPoint == null) {
      return false;
    }
    // Convert start and end points from epoch/quote to screen coordinates
    final Offset startOffset = Offset(
      epochToX(interactableDrawing.startPoint!.epoch),
      quoteToY(interactableDrawing.startPoint!.quote),
    );

    // For horizontal line when we're adding it, we only need to check if the
    // point is near the line's y-coordinate, because it shows the label during
    // the whole process of adding the tool.
    final double distance = (offset.dy - startOffset.dy).abs();
    return distance <= hitTestMargin;
  }

  @override
  String get id => 'Horizontal-line-adding-preview-mobile';

  @override
  void onDragStart(DragStartDetails details, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    interactableDrawing.onDragStart(
        details, epochFromX, quoteFromY, epochToX, quoteToY);
  }

  @override
  void onDragUpdate(DragUpdateDetails details, EpochFromX epochFromX,
      QuoteFromY quoteFromY, EpochToX epochToX, QuoteToY quoteToY) {
    interactableDrawing.onDragUpdate(
      details,
      epochFromX,
      quoteFromY,
      epochToX,
      quoteToY,
    );
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
    GetDrawingState drawingState,
  ) {
    // Only paint if we have a valid start point
    if (interactableDrawing.startPoint != null) {
      // Delegate to main drawing with selected state simulation for full visual appearance
      Set<DrawingToolState> mockGetDrawingState(DrawingV2 drawing) =>
          {DrawingToolState.selected};

      interactableDrawing.paint(
        canvas,
        size,
        epochToX,
        quoteToY,
        animationInfo,
        chartConfig,
        chartTheme,
        mockGetDrawingState,
      );
    }
  }

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
    GetDrawingState getDrawingState,
  ) {
    // Only paint if we have a valid start point
    if (interactableDrawing.startPoint != null) {
      // Delegate to main drawing for consistent Y-axis labeling with neon effects
      Set<DrawingToolState> mockGetDrawingState(DrawingV2 drawing) =>
          {DrawingToolState.selected};

      interactableDrawing.paintOverYAxis(
        canvas,
        size,
        epochToX,
        quoteToY,
        epochFromX,
        quoteFromY,
        animationInfo,
        chartConfig,
        chartTheme,
        mockGetDrawingState,
      );
    }
  }

  @override
  void onCreateTap(
    TapUpDetails details,
    EpochFromX epochFromX,
    QuoteFromY quoteFromY,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    // Since we immediately complete the adding process in the constructor,
    // this method is primarily for consistency with the interface.
    // The line is already positioned and in focus mode.

    // If for some reason the start point is not set, set it to the tap position
    interactableDrawing.startPoint ??= EdgePoint(
      epoch: epochFromX(details.localPosition.dx),
      quote: quoteFromY(details.localPosition.dy),
    );

    // Ensure we're in completed state
    onAddingStateChange(AddingStateInfo(1, 1));
  }
}
