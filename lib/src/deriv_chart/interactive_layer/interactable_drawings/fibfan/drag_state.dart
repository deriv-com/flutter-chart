/// Enum representing the different drag states for Fibonacci Fan drawing tool.
///
/// This enum provides clear, explicit states for drag interactions, improving
/// code readability and reducing the risk of misinterpreting the drag state
/// compared to using a nullable boolean.
enum FibfanDragState {
  /// User is dragging the start point of the fan.
  ///
  /// In this state, only the start point moves while the end point remains fixed.
  /// This allows users to adjust the origin of the Fibonacci fan lines.
  draggingStartPoint,

  /// User is dragging the end point of the fan.
  ///
  /// In this state, only the end point moves while the start point remains fixed.
  /// This allows users to adjust the direction and scale of the Fibonacci fan lines.
  draggingEndPoint,

  /// User is dragging the entire fan.
  ///
  /// In this state, both start and end points move together, maintaining their
  /// relative positions. This allows users to reposition the entire fan without
  /// changing its shape or orientation.
  draggingEntireFan,
}
