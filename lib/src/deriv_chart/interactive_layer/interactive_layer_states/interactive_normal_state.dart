import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../interactable_drawings/interactable_drawing.dart';
import '../enums/state_change_direction.dart';
import 'interactive_hover_state.dart';
import 'interactive_selected_tool_state.dart';
import 'interactive_state.dart';

/// The normal state of the interactive layer.
///
/// This class represents the default state of the [InteractiveLayer] when no tools
/// are selected or being added. In this state, tapping on a drawing will select it
/// and transition to the [InteractiveSelectedToolState].
///
/// This is the initial state of the interactive layer and the state it returns to
/// when a tool is deselected or after a tool has been added.
class InteractiveNormalState extends InteractiveState
    with InteractiveHoverState {
  /// Initializes the state with the interactive layer.
  ///
  /// The [interactiveLayer] parameter is passed to the superclass and provides
  /// access to the layer's methods and properties.
  InteractiveNormalState({required super.interactiveLayerBehaviour});

  @override
  bool onPanStart(DragStartDetails details) {
    final InteractableDrawing<DrawingToolConfig>? hitDrawing =
        anyDrawingHit(details.localPosition);

    if (hitDrawing == null) {
      return false; // No drawing was hit
    }

    final InteractiveState newState = InteractiveSelectedToolState(
      selected: hitDrawing,
      interactiveLayerBehaviour: interactiveLayerBehaviour,
    );

    interactiveLayerBehaviour.updateStateTo(
      newState,
      StateChangeAnimationDirection.forward,
      waitForAnimation: false,
    );

    newState.onPanStart(details);
    return true; // A drawing was hit
  }

  @override
  bool onTap(TapUpDetails details) {
    final InteractableDrawing<DrawingToolConfig>? hitDrawing = anyDrawingHit(
      details.localPosition,
    );

    if (hitDrawing == null) {
      return false; // No drawing was hit
    }

    interactiveLayerBehaviour.updateStateTo(
      InteractiveSelectedToolState(
        selected: hitDrawing,
        interactiveLayerBehaviour: interactiveLayerBehaviour,
      ),
      StateChangeAnimationDirection.forward,
      waitForAnimation: false,
    );

    return true; // A drawing was hit
  }
}
