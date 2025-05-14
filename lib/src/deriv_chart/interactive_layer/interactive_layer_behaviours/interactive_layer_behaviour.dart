import 'dart:async';
import 'dart:ui';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import 'package:flutter/gestures.dart';

import '../enums/drawing_tool_state.dart';
import '../enums/state_change_direction.dart';
import '../interactable_drawings/drawing_adding_preview.dart';
import '../interactable_drawings/drawing_v2.dart';
import '../interactable_drawings/interactable_drawing.dart';
import '../interactive_layer_base.dart';
import '../interactive_layer_states/interactive_adding_tool_state.dart';
import '../interactive_layer_states/interactive_normal_state.dart';
import '../interactive_layer_states/interactive_state.dart';

/// The base class for managing [InteractiveLayerBase]'s behaviour according to
/// a platform or a condition.
/// [InteractiveLayerBase] uses this to manage gestures and the layer state in
/// every scenarios.
/// The way we're handling the gestures and [_interactiveState] transitions can
/// be customized by extending this class.
///
/// Check out [InteractiveLayerMobileBehaviour] and
/// [InteractiveLayerDesktopBehaviour] to see specific implementations for two
/// different platforms.
abstract class InteractiveLayerBehaviour {
  late InteractiveState _interactiveState;

  /// Initializes the interactive layer manager.
  void init({
    required InteractiveLayerBase interactiveLayer,
    required VoidCallback onUpdate,
  }) {
    this.interactiveLayer = interactiveLayer;
    this.onUpdate = onUpdate;
    _interactiveState = InteractiveNormalState(interactiveLayerBehaviour: this);
  }

  /// Return the adding preview of the [drawing] we're currently adding for this
  /// Behaviour.
  DrawingAddingPreview getAddingDrawingPreview(InteractableDrawing drawing);

  /// Updates the interactive layer state to the new state.
  Future<void> updateStateTo(
    InteractiveState newState,
    StateChangeAnimationDirection direction, {
    bool waitForAnimation = false,
  }) async {
    if (waitForAnimation) {
      await interactiveLayer.animateStateChange(direction);

      _interactiveState = newState;
      onUpdate();
    } else {
      unawaited(interactiveLayer.animateStateChange(direction));

      _interactiveState = newState;
      onUpdate();
    }
  }

  /// Handles the addition of a drawing tool.
  void onAddDrawingTool(DrawingToolConfig drawingTool) {
    updateStateTo(
      InteractiveAddingToolState(drawingTool, interactiveLayerBehaviour: this),
      StateChangeAnimationDirection.forward,
    );
  }

  /// The interactive layer that this manager is managing.
  late final InteractiveLayerBase interactiveLayer;

  /// The callback that is called when the interactive layer needs to be
  late final VoidCallback onUpdate;

  /// The drawings of the interactive layer.
  Set<DrawingToolState> getToolState(DrawingV2 drawing) =>
      _interactiveState.getToolState(drawing);

  /// The extra drawings that the current interactive state can show in
  /// [InteractiveLayerBase].
  ///
  /// These [previewDrawings] are usually supposed to be drawings that have
  /// shorter lifespan just for preview or showing a temporary guids when user
  /// is interacting with [InteractiveLayerBase].
  List<DrawingV2> get previewDrawings => _interactiveState.previewDrawings;

  /// Handles tap event.
  void onTap(TapUpDetails details) {
    _interactiveState.onTap(details);
  }

  /// Handles pan update event.
  void onPanUpdate(DragUpdateDetails details) {
    _interactiveState.onPanUpdate(details);
  }

  /// Handles pan end event.
  void onPanEnd(DragEndDetails details) {
    _interactiveState.onPanEnd(details);
  }

  /// Handles pan start event.
  void onPanStart(DragStartDetails details) {
    _interactiveState.onPanStart(details);
  }

  /// Handles hover event.
  void onHover(PointerHoverEvent event) {
    _interactiveState.onHover(event);
  }
}
