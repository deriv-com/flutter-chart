import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../helpers/types.dart';
import '../interactable_drawings/drawing_v2.dart';
import '../interactable_drawings/interactable_drawing.dart';
import '../interactive_layer_states/interactive_state.dart';
import '../enums/drawing_tool_state.dart';
import '../enums/state_change_direction.dart';
import '../widgets/selected_drawing_floating_menu.dart';
import 'interactive_hover_state.dart';
import 'interactive_normal_state.dart';

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
  DrawingZOrder getToolZOrder(DrawingV2 drawing) {
    if (drawing.id == selected.config.configId) {
      return DrawingZOrder.top;
    }

    return super.getToolZOrder(drawing);
  }

  @override
  bool onPanEnd(DragEndDetails details) {
    if (_draggingStartedOnTool) {
      selected.onDragEnd(details, epochFromX, quoteFromY, epochToX, quoteToY);
      _draggingStartedOnTool = false;
      interactiveLayer.saveDrawing(selected.getUpdatedConfig());
      return true; // Ended dragging a tool
    }
    return false; // Not dragging a tool
  }

  @override
  bool onPanStart(DragStartDetails details) {
    if (selected.hitTest(details.localPosition, epochToX, quoteToY)) {
      selected.onDragStart(details, epochFromX, quoteFromY, epochToX, quoteToY);
      return true; // Started dragging on the selected tool
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
          waitForAnimation: false,
          animate: false,
        );
        return true; // Started dragging on another tool
      }
      return false; // No tool was hit
    }
  }

  @override
  bool onPanUpdate(DragUpdateDetails details) {
    if (!_draggingStartedOnTool) {
      _draggingStartedOnTool = true;
    }

    selected.onDragUpdate(
      details,
      epochFromX,
      quoteFromY,
      epochToX,
      quoteToY,
    );
    return true; // Dragging a tool
  }

  @override
  bool onTap(TapUpDetails details) {
    final InteractableDrawing<DrawingToolConfig>? hitDrawing =
        anyDrawingHit(details.localPosition);

    if (hitDrawing?.id == selected.id) {
      // If the tapped drawing is the same as the selected one, do nothing.
      return true; // Indicate tap was handled even though nothing was done.
    }

    if (hitDrawing != null) {
      // when a tool is tap/hit, keep selected state. it might be the same
      // tool or a different tool.
      interactiveLayerBehaviour.updateStateTo(
        InteractiveSelectedToolState(
          selected: hitDrawing,
          interactiveLayerBehaviour: interactiveLayerBehaviour,
        ),
        StateChangeAnimationDirection.forward,
        waitForAnimation: false,
        animate: false,
      );
      return true; // A drawing was hit
    } else {
      // If tap is on empty space, return to normal state.
      interactiveLayerBehaviour.updateStateTo(
        InteractiveNormalState(
            interactiveLayerBehaviour: interactiveLayerBehaviour),
        StateChangeAnimationDirection.backward,
      );
      return false; // No drawing was hit
    }
  }

  @override
  bool onHover(PointerHoverEvent event) {
    return getToolState(selected).contains(DrawingToolState.dragging);
  }

  @override
  List<Widget> get previewWidgets => [_buildSelectedDrawingFloatingMenu()];

  Widget _buildSelectedDrawingFloatingMenu() => SelectedDrawingFloatingMenu(
        drawing: selected,
        interactiveLayerBehaviour: interactiveLayerBehaviour,
        onUpdateDrawing: (config) {
          interactiveLayer.saveDrawing(config);
          interactiveLayerBehaviour.updateStateTo(
            this,
            StateChangeAnimationDirection.forward,
            animate: false,
          );
        },
        onRemoveDrawing: (config) {
          if (selected.id != config.configId) {
            return;
          }

          interactiveLayerBehaviour.updateStateTo(
            InteractiveNormalState(
              interactiveLayerBehaviour: interactiveLayerBehaviour,
            ),
            StateChangeAnimationDirection.backward,
            waitForAnimation: false,
          );

          interactiveLayer.removeDrawing(config);
        },
      );
}
