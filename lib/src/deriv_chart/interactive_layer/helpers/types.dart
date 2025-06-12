import '../enums/drawing_tool_state.dart';
import '../interactable_drawings/drawing_v2.dart';

/// A callback which calling it should return if the [drawing] is selected.
typedef GetDrawingState = Set<DrawingToolState> Function(
  DrawingV2 drawing,
);
