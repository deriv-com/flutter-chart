import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:flutter/gestures.dart';

import '../enums/drawing_tool_state.dart';
import '../interactable_drawings/drawing_v2.dart';
import '../interactable_drawings/interactable_drawing.dart';
import 'interactive_state.dart';

/// The state of the interactive layer when a tool is hovered.
///
/// Defined as mixin so that it can be combined with other states meaning that
/// other states can also have hover functionality.
mixin InteractiveHoverState on InteractiveState {
  InteractableDrawing<DrawingToolConfig>? _hoveredTool;

  @override
  Set<DrawingToolState> getToolState(DrawingV2 drawing) =>
      drawing == _hoveredTool
          ? {DrawingToolState.hovered}
          : {DrawingToolState.normal};

  @override
  bool onHover(PointerHoverEvent event) {
    super.onHover(event);

    final hoveredTool = anyDrawingHit(event.localPosition);

    if (hoveredTool == _hoveredTool) {
      return hoveredTool != null;
    }

    if (hoveredTool != _hoveredTool) {
      _hoveredTool = hoveredTool;
    } else {
      _hoveredTool = null;
    }

    return hoveredTool != null;
  }
}
