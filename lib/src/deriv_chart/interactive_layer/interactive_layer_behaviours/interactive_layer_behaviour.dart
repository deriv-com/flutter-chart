import 'dart:async';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/helpers/types.dart';
import 'package:deriv_chart/src/misc/chart_diagnostics.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../enums/drawing_tool_state.dart';
import '../enums/state_change_direction.dart';
import '../interactable_drawings/drawing_adding_preview.dart';
import '../interactable_drawings/drawing_v2.dart';
import '../interactable_drawings/interactable_drawing.dart';
import '../interactive_layer_base.dart';
import '../interactive_layer_controller.dart';
import '../interactive_layer_states/interactive_adding_tool_state.dart';
import '../interactive_layer_states/interactive_normal_state.dart';
import '../interactive_layer_states/interactive_selected_tool_state.dart';
import '../interactive_layer_states/interactive_state.dart';

/// The base class for managing [InteractiveLayerBase]'s behaviour according to
/// a platform or a condition.
/// [InteractiveLayerBase] uses this to manage gestures and the layer state in
/// every scenarios.
/// The way we're handling the gestures and [currentState] transitions can
/// be customized by extending this class.
///
/// Check out [InteractiveLayerMobileBehaviour] and
/// [InteractiveLayerDesktopBehaviour] to see specific implementations for two
/// different platforms.
abstract class InteractiveLayerBehaviour {
  /// Creates an instance of [InteractiveLayerBehaviour].
  InteractiveLayerBehaviour({
    InteractiveLayerController? controller,
  }) : _controller = controller ?? InteractiveLayerController() {
    _controller
      ..currentState = InteractiveNormalState(interactiveLayerBehaviour: this)
      ..onCancelAdding = () {
        updateStateTo(
          InteractiveNormalState(interactiveLayerBehaviour: this),
          StateChangeAnimationDirection.backward,
          animate: false,
        );
      }
      ..onAddNewTool = (DrawingToolConfig drawingTool) {
        startAddingTool(drawingTool);
      };
  }

  late final InteractiveLayerController _controller;

  /// Resets the interactive layer to [InteractiveNormalState], dropping any
  /// current selection or in-progress adding state. Safe to call before the
  /// layer has mounted — bypasses [updateStateTo] which requires [interactiveLayer]
  /// to be initialised. No-op if already in normal state.
  void resetToNormalState() {
    if (currentState is! InteractiveNormalState) {
      _controller.currentState =
          InteractiveNormalState(interactiveLayerBehaviour: this);
    }
  }

  /// The controller for state changes in the interactive layer.
  ///
  /// Note: This is not final to allow reassignment when the widget rebuilds
  /// (e.g., during symbol switches). The old controller gets disposed by the
  /// widget, and a new one is created and assigned here.
  late AnimationController stateChangeController;

  /// The controller for the interactive layer.
  InteractiveLayerController get controller => _controller;

  /// Current state of the interactive layer.
  InteractiveState get currentState => controller.currentState;

  bool _initialized = false;

  /// Whether [init] has been called at least once, i.e. whether
  /// [interactiveLayer], [onUpdate] and [stateChangeController] are bound.
  bool get isInitialized => _initialized;

  /// The interactive layer that this manager is managing.
  ///
  /// Note: This is not final to allow reassignment when the widget rebuilds.
  late InteractiveLayerBase interactiveLayer;

  /// The callback that is called when the interactive layer needs to be updated.
  ///
  /// Note: This is not final to allow reassignment when the widget rebuilds.
  late VoidCallback onUpdate;

  /// Monotonically increasing id of state transitions. Used to detect when a
  /// transition that was suspended on its animation has been superseded by a
  /// newer one (see [updateStateTo]).
  int _stateTransitionSeq = 0;

  /// Initializes the [InteractiveLayerBehaviour].
  ///
  /// This method can be called multiple times (e.g., when the widget rebuilds
  /// during symbol switches). It will update the references to the new
  /// controller, interactive layer, and callback even if already initialized.
  void init({
    required InteractiveLayerBase interactiveLayer,
    required VoidCallback onUpdate,
    required AnimationController stateChangeController,
  }) {
    if (_initialized) {
      // Update the references to the new instances
      this.stateChangeController = stateChangeController;
      this.interactiveLayer = interactiveLayer;
      this.onUpdate = onUpdate;

      return;
    }

    // First-time initialization
    this.stateChangeController = stateChangeController;
    this.interactiveLayer = interactiveLayer;
    this.onUpdate = onUpdate;
    _initialized = true;
  }

  /// Return the adding preview of the [drawing] we're currently adding for this
  /// Behaviour.
  DrawingAddingPreview getAddingDrawingPreview(
    InteractableDrawing drawing,
    Function(AddingStateInfo) onAddingStateChange,
  );

  /// Updates the interactive layer state to the new state.
  ///
  /// Calls [onUpdate] callback to notify the interactive layer to update its
  /// UI after the state change.
  ///
  /// [waitForAnimation]
  /// If set to `true`, the method will wait for the state change animation.
  /// If set to `false`, it will not wait for the animation to complete.
  /// If `null` will not play animation for state change.
  Future<void> updateStateTo(
    InteractiveState newState,
    StateChangeAnimationDirection direction, {
    bool waitForAnimation = true,
    bool animate = true,
  }) async {
    final int transitionSeq = ++_stateTransitionSeq;

    chartDiag('updateStateTo #$transitionSeq '
        '${_describeState(currentState)} -> ${_describeState(newState)} '
        '(wait: $waitForAnimation, animate: $animate)');

    if (waitForAnimation) {
      await interactiveLayer.animateStateChange(direction, animate: animate);

      // While this transition was suspended on its animation, a newer
      // transition may have started (the await can also resume late after the
      // animation was cancelled by a keyed remount disposing the layer).
      // The newer transition owns the state machine now; applying this one
      // would overwrite it with stale state.
      if (transitionSeq != _stateTransitionSeq) {
        chartDiag('updateStateTo #$transitionSeq superseded by '
            '#$_stateTransitionSeq, dropping ${_describeState(newState)}');
        return;
      }
    } else {
      unawaited(
          interactiveLayer.animateStateChange(direction, animate: animate));
    }

    _controller.currentState = newState;
    chartDiag('updateStateTo #$transitionSeq applied '
        '${_describeState(newState)}');
    onUpdate();
  }

  /// Describes a state for diagnostics, including the selected drawing id
  /// when applicable.
  static String _describeState(InteractiveState state) =>
      state is InteractiveSelectedToolState
          ? '${state.runtimeType}(${state.selected.id})'
          : '${state.runtimeType}';

  /// Handles the addition of a drawing tool.
  /// Will be called when we want to add [drawingTool] to the layer.
  void startAddingTool(DrawingToolConfig drawingTool) {
    updateStateTo(
      InteractiveAddingToolState(drawingTool, interactiveLayerBehaviour: this),
      StateChangeAnimationDirection.forward,
      animate: false,
      waitForAnimation: false,
    );
  }

  /// Will be called right after the process of [startAddingTool] is completed
  /// without cancellation.
  ///
  /// It can be used to perform any additional actions after a new tool is added
  ///
  /// By default, it will update the state to [InteractiveSelectedToolState]
  /// with the newly added drawing.
  void aNewToolsIsAdded(InteractableDrawing drawing) => updateStateTo(
        InteractiveSelectedToolState(
          selected: drawing,
          interactiveLayerBehaviour: this,
        ),
        StateChangeAnimationDirection.forward,
        waitForAnimation: false,
      );

  /// The drawings of the interactive layer.
  Set<DrawingToolState> getToolState(DrawingV2 drawing) =>
      currentState.getToolState(drawing);

  /// Returns the z-order for the tool drawings.
  DrawingZOrder getToolZOrder(DrawingV2 drawing) =>
      currentState.getToolZOrder(drawing);

  /// The extra drawings that the current interactive state can show in
  /// [InteractiveLayerBase].
  ///
  /// These [previewDrawings] are usually meant to be drawings with a shorter
  /// lifespan, used for preview purposes or for showing temporary guides when
  /// the user is interacting with [InteractiveLayerBase].
  List<DrawingV2> get previewDrawings => currentState.previewDrawings;

  /// The extra widgets that the current interactive state can show on top of
  /// interactive layer.
  List<Widget> get previewWidgets => currentState.previewWidgets;

  /// Handles tap event.
  bool onTap(TapUpDetails details) => currentState.onTap(details);

  /// Handles pan update event.
  bool onPanUpdate(DragUpdateDetails details) =>
      currentState.onPanUpdate(details);

  /// Handles pan end event.
  bool onPanEnd(DragEndDetails details) => currentState.onPanEnd(details);

  /// Handles pan start event.
  bool onPanStart(DragStartDetails details) => currentState.onPanStart(details);

  /// Handles hover event.
  bool onHover(PointerHoverEvent event) => currentState.onHover(event);

  /// Handles long press event.
  bool onLongPress(Offset localPosition) =>
      currentState.onLongPress(localPosition);

  /// Handles long press end event.
  bool onLongPressEnd() => currentState.onLongPressEnd();

  /// Checks if a point hits any drawing (both regular drawings and preview drawings).
  ///
  /// This method is used for hit testing to determine if a given local position
  /// intersects with any interactive drawing elements.
  ///
  /// Returns `true` if the position hits any drawing, `false` otherwise.
  bool hitTestDrawings(Offset localPosition) {
    // First check if the point is within the floating menu bounds
    // If it is, don't allow drawing hit testing to prevent interference
    if (controller.isPointInFloatingMenu(localPosition)) {
      return false;
    }

    // Check regular and preview drawings
    for (final drawing in [...interactiveLayer.drawings, ...previewDrawings]) {
      if (drawing.hitTest(localPosition, interactiveLayer.epochToX,
          interactiveLayer.quoteToY)) {
        return true;
      }
    }

    return false;
  }
}
