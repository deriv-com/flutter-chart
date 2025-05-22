import 'package:flutter/gestures.dart';

import 'interactive_adding_tool_state.dart';

/// The mobile-specific implementation of the interactive adding tool state.
class InteractiveAddingToolStateMobile extends InteractiveAddingToolState {
  /// Adding tool state for mobile devices.
  InteractiveAddingToolStateMobile(
    super.addingTool, {
    required super.interactiveLayerBehaviour,
  });

  @override
  void onTap(TapUpDetails details) {
    if (!(addingDrawingPreview?.hitTest(
            details.localPosition, epochToX, quoteToY) ??
        true)) {
      // The tap was outside of the adding drawing preview. This means according
      // to the way we want to have tool addition flow we should set current
      // point's position and go to the next step (next point or finish adding
      // the tool).
      super.onTap(details);
    }
  }
}
