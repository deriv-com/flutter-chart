import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';

// TODO(NA): consider EdgePoint radius as well in this calculation.
/// The distance from the edge point to the edge of the screen to be considered
/// as off screen for a [DraggableEdgePoint].
///
/// This is to make sure the [DraggableEdgePoint] is fully out of the view port.
///
/// Since the position of a [DraggableEdgePoint] is its center point, we should
/// also consider its radius as well if we want to improve this value and make
/// it accurate.
const double _edgePointOffScreenSafeDistance = 1000;

/// An extension on DraggableEdgePoint class that adds some helper methods.
extension DraggableEdgePointExtension on DraggableEdgePoint {
  /// Checks if the edge point is on the view port range.
  ///
  /// The view port range is defined by the left and right epoch values.
  /// returns true if the edge point is on the view port range.
  bool isOnViewPortRange(int leftEpoch, int rightEpoch) =>
      draggedPosition.dx >= (leftEpoch - _edgePointOffScreenSafeDistance) &&
      draggedPosition.dx <= (rightEpoch + _edgePointOffScreenSafeDistance);
}
