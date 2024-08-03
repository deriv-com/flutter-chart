import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';

// TODO(NA): consider EdgePoint radius as well in this calculation.
/// The distance from the left and right sides of the chart viewport that should
/// still be considered part of the visible area. This ensures that a point is
/// fully out of the viewport before it is considered off-screen.
///
/// For [DraggableEdgePoint]s, since the position is defined by its center
/// point, we should also consider its radius to improve accuracy.
/// When we know how the edge point is visually represented (circle, square,
/// etc.), we can refine this value.
///
/// Currently, as a safe distance, we consider half of the screen's viewport
/// from [leftEpoch] to [rightEpoch] as the buffer zone for a point to be
/// considered off-screen. This ensures that the point is fully out of the
/// viewport at all granularities.
///
///       view port      half of screen outside
///    ------^-------- ---^---
///   |               |   *  |    -> edge point is NOT considered as off screen.
///   |               |      |
///   |               |      |  * -> edge point is considered as off screen.
double getPointOffScreenBufferDistance(int leftEpoch, int rightEpoch) =>
    (rightEpoch - leftEpoch) / 2;

/// An extension on DraggableEdgePoint class that adds some helper methods.
extension DraggableEdgePointExtension on DraggableEdgePoint {
  /// Checks if the edge point is on the view port range.
  ///
  /// The view port range is defined by the left and right epoch values.
  /// returns true if the edge point is on the view port range.
  bool isInViewPortRange(int leftEpoch, int rightEpoch) =>
      draggedEdgePoint.epoch >=
          (leftEpoch -
              getPointOffScreenBufferDistance(leftEpoch, rightEpoch)) &&
      draggedEdgePoint.epoch <=
          (rightEpoch + getPointOffScreenBufferDistance(leftEpoch, rightEpoch));
}
