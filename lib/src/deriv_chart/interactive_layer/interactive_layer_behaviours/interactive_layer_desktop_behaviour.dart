import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';

import '../interactable_drawings/drawing_adding_preview.dart';
import '../interactable_drawings/interactable_drawing.dart';
import 'interactive_layer_behaviour.dart';

/// The Desktop-specific implementation of the interactive layer behaviour.
class InteractiveLayerDesktopBehaviour extends InteractiveLayerBehaviour {
  /// Creates an instance of [InteractiveLayerDesktopBehaviour].
  InteractiveLayerDesktopBehaviour({super.controller});

  @override
  DrawingAddingPreview getAddingDrawingPreview(
    InteractableDrawing<DrawingToolConfig> drawing,
  ) =>
      drawing.getAddingPreviewForDesktopBehaviour(this);
}
