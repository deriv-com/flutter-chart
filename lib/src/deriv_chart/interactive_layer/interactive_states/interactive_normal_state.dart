import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../interactable_drawings/interactable_drawing.dart';
import '../state_change_direction.dart';
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
  InteractiveNormalState({required super.interactiveLayer});

  @override
  void onPanEnd(DragEndDetails details) {}

  @override
  void onPanStart(DragStartDetails details) {
    final InteractableDrawing<DrawingToolConfig>? hitDrawing =
        anyDrawingHit(details.localPosition);

    if (hitDrawing == null) {
      return;
    }

    final InteractiveState newState = InteractiveSelectedToolState(
      selected: hitDrawing,
      interactiveLayer: interactiveLayer,
    );

    interactiveLayer.updateStateTo(
        newState, StateChangeAnimationDirection.forward);

    newState.onPanStart(details);
  }

  @override
  void onPanUpdate(DragUpdateDetails details) {}

  @override
  void onTap(TapUpDetails details) {
    final InteractableDrawing<DrawingToolConfig>? hitDrawing = anyDrawingHit(
      details.localPosition,
    );

    if (hitDrawing == null) {
      return;
    }

    interactiveLayer.updateStateTo(
      InteractiveSelectedToolState(
        selected: hitDrawing,
        interactiveLayer: interactiveLayer,
      ),
      StateChangeAnimationDirection.forward,
    );
  }
}
