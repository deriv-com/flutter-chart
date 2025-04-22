import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:flutter/widgets.dart';

import '../interactable_drawings/interactable_drawing.dart';
import '../state_change_direction.dart';
import 'interactive_hover_state.dart';
import 'interactive_normal_state.dart';
import 'interactive_state.dart';

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
    required super.interactiveLayer,
  });

  /// The selected tool.
  ///
  /// This is the drawing tool that is currently selected and will respond to
  /// manipulation gestures. It will be rendered with a selected appearance.
  final InteractableDrawing selected;

  bool _draggingStartedOnTool = false;

  @override
  Set<DrawingToolState> getToolState(
    InteractableDrawing<DrawingToolConfig> drawing,
  ) {
    final Set<DrawingToolState> hoveredState = super.getToolState(drawing);

    // If this is the selected drawing
    if (drawing.config.configId == selected.config.configId) {
      // Return dragging state if we're currently dragging the tool
      if (_draggingStartedOnTool) {
        return hoveredState..add(DrawingToolState.dragging);
      }
      // Otherwise return selected state
      return hoveredState..add(DrawingToolState.selected);
    }

    // For all other drawings, return normal state
    return hoveredState;
  }

  @override
  void onPanEnd(DragEndDetails details) {
    selected.onDragEnd(details, epochFromX, quoteFromY, epochToX, quoteToY);
    _draggingStartedOnTool = false;
    interactiveLayer.onSaveDrawing(selected);
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
        interactiveLayer.updateStateTo(
          InteractiveSelectedToolState(
            selected: hitDrawing,
            interactiveLayer: interactiveLayer,
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

      interactiveLayer.onSaveDrawing(selected);
    }
  }

  @override
  void onTap(TapUpDetails details) {
    final InteractableDrawing<DrawingToolConfig>? hitDrawing =
        anyDrawingHit(details.localPosition);

    if (hitDrawing != null) {
      // when a tool is tap/hit, keep selected state. it might be the same
      // tool or a different tool.
      interactiveLayer.updateStateTo(
        InteractiveSelectedToolState(
          selected: hitDrawing,
          interactiveLayer: interactiveLayer,
        ),
        StateChangeAnimationDirection.forward,
      );
    } else {
      // If tap is on empty space, return to normal state.
      interactiveLayer.updateStateTo(
        InteractiveNormalState(interactiveLayer: interactiveLayer),
        StateChangeAnimationDirection.backward,
        waitForAnimation: true,
      );
    }
  }
}
