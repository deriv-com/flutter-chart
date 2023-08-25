import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';

/// An extension on DraggableEdgePoint class that adds some helper methods.
extension DraggableEdgePointExtension on DraggableEdgePoint {
  /// Checks if the edge point is on the view port range.
  ///
  /// The view port range is defined by the left and right epoch values.
  /// returns true if the edge point is on the view port range.
  bool isOnViewPortRange(int leftEpoch, int rightEpoch) =>
      draggedPosition.dx >= (leftEpoch - 1000) &&
      draggedPosition.dx <= (rightEpoch + 1000);
}
