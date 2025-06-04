import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/widgets.dart';

import '../enums/drawing_tool_state.dart';
import '../enums/state_change_direction.dart';

/// The state of the interactive layer when a tool is selected.
///
/// This class represents the state of the [InteractiveLayer] when a drawing tool
/// is selected by the user. In this state, the selected tool can be manipulated
/// through drag gestures, and tapping on empty space will return to the normal state.
///
/// It handles user interactions specifically for when a drawing tool is selected,
/// providing appropriate responses to gestures and maintaining the selected state.
class InteractiveSelectedToolState extends InteractiveState
    with InteractiveHoverState {
  /// Initializes the state with the interactive layer and the [selected] tool.
  ///
  /// The [selected] parameter is the drawing tool that has been selected by the user
  /// and will respond to manipulation gestures.
  ///
  /// The [interactiveLayer] parameter is passed to the superclass and provides
  /// access to the layer's methods and properties.
  InteractiveSelectedToolState({
    required this.selected,
    required super.interactiveLayerBehaviour,
  });

  /// The selected tool.
  ///
  /// This is the drawing tool that is currently selected and will respond to
  /// manipulation gestures. It will be rendered with a selected appearance.
  final InteractableDrawing selected;

  bool _draggingStartedOnTool = false;

  @override
  Set<DrawingToolState> getToolState(DrawingV2 drawing) {
    final Set<DrawingToolState> hoveredState = super.getToolState(drawing);

    // If this is the selected drawing
    if (drawing.id == selected.config.configId) {
      // Return dragging state if we're currently dragging the tool
      if (_draggingStartedOnTool) {
        hoveredState.add(DrawingToolState.dragging);
      }
      // Otherwise add selected state
      hoveredState.add(DrawingToolState.selected);
    }

    if (interactiveLayer.stateChangeAnimationController != null &&
        interactiveLayer.stateChangeAnimationController!.isAnimating) {
      hoveredState.add(DrawingToolState.animating);
    }

    // For all other drawings, return normal state
    return hoveredState;
  }

  @override
  void onPanEnd(DragEndDetails details) {
    selected.onDragEnd(details, epochFromX, quoteFromY, epochToX, quoteToY);
    _draggingStartedOnTool = false;
    interactiveLayer.saveDrawing(selected);
  }

  @override
  void onPanStart(DragStartDetails details) {
    if (selected.hitTest(details.localPosition, epochToX, quoteToY)) {
      _draggingStartedOnTool = true;
      selected.onDragStart(details, epochFromX, quoteFromY, epochToX, quoteToY);
    } else {
      final InteractableDrawing<DrawingToolConfig>? hitDrawing =
          anyDrawingHit(details.localPosition);

      // If a tool is selected, but user starts dragging on another tool
      // Switch the selected tool
      if (hitDrawing != null) {
        interactiveLayerBehaviour.updateStateTo(
          InteractiveSelectedToolState(
            selected: hitDrawing,
            interactiveLayerBehaviour: interactiveLayerBehaviour,
          )..onPanStart(details),
          StateChangeAnimationDirection.forward,
        );
      }
    }
  }

  @override
  void onPanUpdate(DragUpdateDetails details) {
    if (_draggingStartedOnTool) {
      selected.onDragUpdate(
        details,
        epochFromX,
        quoteFromY,
        epochToX,
        quoteToY,
      );
    }
  }

  @override
  void onTap(TapUpDetails details) {
    final InteractableDrawing<DrawingToolConfig>? hitDrawing =
        anyDrawingHit(details.localPosition);

    if (hitDrawing != null) {
      // when a tool is tap/hit, keep selected state. it might be the same
      // tool or a different tool.
      interactiveLayerBehaviour.updateStateTo(
        InteractiveSelectedToolState(
          selected: hitDrawing,
          interactiveLayerBehaviour: interactiveLayerBehaviour,
        ),
        StateChangeAnimationDirection.forward,
      );
    } else {
      // If tap is on empty space, return to normal state.
      interactiveLayerBehaviour.updateStateTo(
        InteractiveNormalState(
            interactiveLayerBehaviour: interactiveLayerBehaviour),
        StateChangeAnimationDirection.backward,
        waitForAnimation: true,
      );
    }
  }
}
