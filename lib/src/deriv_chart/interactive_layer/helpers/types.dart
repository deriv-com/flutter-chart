import '../enums/drawing_tool_state.dart';
import '../interactable_drawings/drawing_v2.dart';

/// A callback which calling it should return if the [drawing] is selected.
typedef GetDrawingState = Set<DrawingToolState> Function(
  DrawingV2 drawing,
);

/// A callback which calling it should return the z-order of the [drawing].
typedef GetDrawingZOrder = DrawingZOrder Function(
  DrawingV2 drawing,
);

/// A callback which calling it should return the updated config of the
enum DrawingZOrder {
  /// The drawing is at the bottom of the stack.
  bottom(0),

  /// The drawing is at the top of the stack.
  top(1);

  /// Creates a new [DrawingZOrder] with the given order.
  const DrawingZOrder(this.order);

  /// The order of the drawing in the stack.
  final int order;
}
