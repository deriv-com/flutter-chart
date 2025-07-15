import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';

import '../enums/state_change_direction.dart';
import '../interactable_drawings/drawing_adding_preview.dart';
import '../interactable_drawings/interactable_drawing.dart';
import '../interactive_layer_states/interactive_adding_tool_state.dart';
import '../interactive_layer_states/interactive_adding_tool_state_mobile.dart';
import 'interactive_layer_behaviour.dart';

/// The mobile-specific implementation of the interactive layer behaviour.
class InteractiveLayerMobileBehaviour extends InteractiveLayerBehaviour {
  /// Creates an instance of [InteractiveLayerMobileBehaviour].
  InteractiveLayerMobileBehaviour({super.controller});

  @override
  void startAddingTool(DrawingToolConfig drawingTool) {
    final newState = InteractiveAddingToolStateMobile(
      drawingTool,
      interactiveLayerBehaviour: this,
    );

    updateStateTo(
      newState,
      StateChangeAnimationDirection.backward,
      waitForAnimation: false,
      animate: false,
    );
  }

  @override
  DrawingAddingPreview getAddingDrawingPreview(
    InteractableDrawing<DrawingToolConfig> drawing,
    Function(AddingStateInfo) onAddingStateChange,
  ) =>
      drawing.getAddingPreviewForMobileBehaviour(this, onAddingStateChange);
}
