import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:flutter/gestures.dart';

import '../interactable_drawings/interactable_drawing.dart';
import '../state_change_direction.dart';
import 'interactive_hover_state.dart';
import 'interactive_normal_state.dart';
import 'interactive_selected_tool_state.dart';
import 'interactive_state.dart';

/// The state of the interactive layer when a tool is being added.
///
/// This class represents the state of the [InteractiveLayer] when a new drawing tool
/// is being added to the chart. In this state, tapping on the chart will create a new
/// drawing of the specified type.
///
/// After the drawing is created, the interactive layer transitions back to the
/// [InteractiveNormalState].
class InteractiveAddingToolState extends InteractiveState
    with InteractiveHoverState {
  /// Initializes the state with the interactive layer and the [addingTool].
  ///
  /// The [addingTool] parameter specifies the configuration for the type of drawing
  /// tool that will be created when the user taps on the chart.
  ///
  /// The [interactiveLayer] parameter is passed to the superclass and provides
  /// access to the layer's methods and properties.
  InteractiveAddingToolState(
    this.addingTool, {
    required super.interactiveLayer,
  }) {
    _addingDrawing ??= addingTool.getInteractableDrawing();
  }

  /// The tool being added.
  ///
  /// This configuration defines the type of drawing that will be created
  /// when the user taps on the chart.
  final DrawingToolConfig addingTool;

  /// The drawing that is currently being created.
  ///
  /// This is initialized when the user first taps on the chart and is used
  /// to render a preview of the drawing being added.
  InteractableDrawing<DrawingToolConfig>? _addingDrawing;

  @override
  List<InteractableDrawing<DrawingToolConfig>> get previewDrawings =>
      [if (_addingDrawing != null) _addingDrawing!];

  @override
  Set<DrawingToolState> getToolState(
    InteractableDrawing<DrawingToolConfig> drawing,
  ) =>
      drawing.config.configId == addingTool.configId
          ? {DrawingToolState.adding}
          : {DrawingToolState.normal};

  @override
  bool onHover(PointerHoverEvent event) {
    _addingDrawing?.onHover(
      event,
      epochFromX,
      quoteFromY,
      epochToX,
      quoteToY,
    );
    
    return true; // Always return true as we're in adding mode
  }

  @override
  bool onTap(TapUpDetails details) {
    _addingDrawing!
        .onCreateTap(details, epochFromX, quoteFromY, epochToX, quoteToY, () {
      interactiveLayer.clearAddingDrawing();

      final DrawingToolConfig addedConfig =
          interactiveLayer.onAddDrawing(_addingDrawing!);

      for (final drawing in interactiveLayer.drawings) {
        if (drawing.config.configId == addedConfig.configId) {
          interactiveLayer.updateStateTo(
            InteractiveSelectedToolState(
              selected: drawing,
              interactiveLayer: interactiveLayer,
            ),
            StateChangeAnimationDirection.forward,
          );
          break;
        }
      }
    });
    
    return true; // Always return true as we're in adding mode
  }

}
