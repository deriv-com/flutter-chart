import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/models/axis_range.dart';

import '../drawing_tools/data_model/edge_point.dart';

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
    (rightEpoch - leftEpoch) / 4;

/// Similar to [getPointOffScreenBufferDistance], but for the quote range.
double getQuoteBufferDistance(double topQuote, double bottomQuote) =>
    (topQuote - bottomQuote) / 4;

/// An extension on DraggableEdgePoint class that adds some helper methods.
extension DraggableEdgePointExtension on DraggableEdgePoint {
  /// Checks if the edge point is on the view port range.
  ///
  /// The view port range is defined by the left and right epoch values.
  /// returns true if the edge point is on the view port range.
  bool isInViewPortRange(int leftEpoch, int rightEpoch) =>
      draggedEdgePoint.isInEpochRange(leftEpoch, rightEpoch);
}

/// An extension on DraggableEdgePoint class that adds some helper methods.
extension EdgePointExtension on EdgePoint {
  /// Checks if the edge point is on the view port range.
  ///
  /// The view port range is defined by the left and right epoch values.
  /// returns true if the edge point is on the view port range.
  bool isInEpochRange(int leftEpoch, int rightEpoch) =>
      epoch >=
          (leftEpoch -
              getPointOffScreenBufferDistance(leftEpoch, rightEpoch)) &&
      epoch <=
          (rightEpoch + getPointOffScreenBufferDistance(leftEpoch, rightEpoch));

  /// Whether the point is in the quote range.
  bool isInQuoteRange(QuoteRange quoteRange) {
    final double topQuote = quoteRange.topQuote;
    final double bottomQuote = quoteRange.bottomQuote;
    final double quoteLengthBuffer =
        getQuoteBufferDistance(topQuote, bottomQuote);

    return (quote <= (topQuote + quoteLengthBuffer)) &&
        (quote >= (bottomQuote - quoteLengthBuffer));
  }

  /// Whether the point is in the view port range. horizontally and vertically.
  bool isInViewPortRange(EpochRange epochRange, QuoteRange quoteRange) =>
      isInEpochRange(epochRange.leftEpoch, epochRange.rightEpoch) ||
      isInQuoteRange(quoteRange);
}
