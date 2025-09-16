import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/enums/drawing_tool_state.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../helpers/types.dart';
import '../../interactive_layer_states/interactive_adding_tool_state.dart';
import '../drawing_v2.dart';
import 'trend_line_adding_preview.dart';

/// Mobile-specific implementation for trend line adding preview.
///
/// This class handles trend line creation and preview specifically for mobile/touch
/// environments where users interact via touch gestures. It extends
/// [TrendLineAddingPreview] to inherit shared functionality while implementing
/// mobile-specific interaction patterns optimized for touch interfaces.
///
/// This mobile preview provides immediate focus mode by:
/// - Automatically placing the trend line in the center of the chart
/// - Immediately completing the adding process for instant focus mode
/// - Delegating visual rendering to the main drawing for consistency
/// - Providing full functionality (drag points, neon effects, proper labeling)
///
/// ## Mobile Interaction Flow:
/// 1. **Auto-Initialization**: Automatically creates centered start and end points
/// 2. **Immediate Focus**: Instantly transitions to selected state with full functionality
/// 3. **Drag Interaction**: Users can drag individual points or the entire line
/// 4. **Full Visual Feedback**: Shows neon effects, focused circles, and alignment guides
///
/// ## Key Features:
/// - **Immediate Focus Mode**: No preview phase, instant selected state
/// - **Touch-Optimized**: Full drag functionality for repositioning points and lines
/// - **Visual Consistency**: Identical appearance to the main drawing
/// - **Centered Positioning**: Intelligent default placement in chart center
///
/// ## Default Positioning:
/// When initialized, the trend line is automatically positioned with:
/// - Start point at bottom-left area (20% from left, 80% from top)
/// - End point at upper-right area (70% from left, 25% from top)
/// - This provides a diagonal trend line spanning nicely across the chart
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
class TrendLineAddingPreviewMobile extends TrendLineAddingPreview {
  /// Initializes [TrendLineInteractableDrawing].
  TrendLineAddingPreviewMobile({
    required super.interactiveLayerBehaviour,
    required super.interactableDrawing,
    required super.onAddingStateChange,
  }) {
    if (interactableDrawing.startPoint == null) {
      final interactiveLayer = interactiveLayerBehaviour.interactiveLayer;
      final Size size = interactiveLayer.drawingContext.fullSize;

      // Position trend line to span chart area with better spacing from Y-axis
      // Start point at center-left area (about 20% from left, 80% from top)
      final startX = size.width * 0.20;
      final startY = size.height * 0.8;

      // End point at center-right area (about 70% from left, 25% from top)
      final endX = size.width * 0.70;
      final endY = size.height * 0.25;

      final startCenter = Offset(startX, startY);
      final endCenter = Offset(endX, endY);

      interactableDrawing
        ..startPoint = EdgePoint(
          epoch: interactiveLayer.epochFromX(startCenter.dx),
          quote: interactiveLayer.quoteFromY(startCenter.dy),
        )
        ..endPoint = EdgePoint(
          epoch: interactiveLayer.epochFromX(endCenter.dx),
          quote: interactiveLayer.quoteFromY(endCenter.dy),
        );

      // Use a post-frame callback to ensure points are fully set before transitioning
      // Check if the widget is still mounted to prevent race conditions
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Check if the interactive layer is still mounted and points are valid
        if (interactiveLayerBehaviour.interactiveLayer.isStillMounted &&
            interactableDrawing.startPoint != null &&
            interactableDrawing.endPoint != null) {
          onAddingStateChange(AddingStateInfo(1, 1));
        }
      });
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
    // Only paint if we have valid start and end points
    if (interactableDrawing.startPoint != null &&
        interactableDrawing.endPoint != null) {
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
      GetDrawingState getDrawingState) {
    // Only paint if we have valid start and end points
    if (interactableDrawing.startPoint != null &&
        interactableDrawing.endPoint != null) {
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
    // The trend line is already positioned and in focus mode.

    // If for some reason the points are not set, set them to default positions
    if (interactableDrawing.startPoint == null ||
        interactableDrawing.endPoint == null) {
      final interactiveLayer = interactiveLayerBehaviour.interactiveLayer;
      final Size size = interactiveLayer.drawingContext.fullSize;

      // Use the same positioning as in the constructor
      final startX = size.width * 0.20;
      final startY = size.height * 0.8;
      final endX = size.width * 0.70;
      final endY = size.height * 0.25;

      final startCenter = Offset(startX, startY);
      final endCenter = Offset(endX, endY);

      interactableDrawing
        ..startPoint = EdgePoint(
          epoch: epochFromX(startCenter.dx),
          quote: quoteFromY(startCenter.dy),
        )
        ..endPoint = EdgePoint(
          epoch: epochFromX(endCenter.dx),
          quote: quoteFromY(endCenter.dy),
        );
    }

    // Ensure we're in completed state
    onAddingStateChange(AddingStateInfo(1, 1));
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
