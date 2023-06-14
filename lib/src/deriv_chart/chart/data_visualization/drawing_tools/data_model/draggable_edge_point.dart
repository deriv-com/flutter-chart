import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';

/// A class that holds draggable edge point data.
/// Draggable edge points are part of the drawings which added by user clicks
/// And we want to hanle difftent types of drag events on them.
/// For example with dots are draggable edge points for the line
/// ⎯⎯⚪️⎯⎯⎯⚪️⎯⎯
class DraggableEdgePoint extends EdgePoint {
  /// Initializes
  DraggableEdgePoint({
    int epoch = 0,
    double yCoord = 0,
  }) : super(epoch: epoch, yCoord: yCoord);

  /// Represents whether the whole drawing is currently being dragged or not
  bool isDrawingDragged = false;

  /// Represents whether the edge point is currently being dragged or not
  bool isDragged = false;

  /// Holds the current position of the edge point when it is being dragged.
  Offset draggedPosition = Offset.zero;

  /// A callback method that takes the relative x and y positions as parameter,
  /// sets the draggedPosition field to its value and return epoch and quote
  /// values.
  Point updatePosition(
    int epoch,
    double yCoord,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
  ) {
    final Offset oldPosition = Offset(epoch.toDouble(), yCoord);
    draggedPosition = isDrawingDragged ? draggedPosition : oldPosition;

    final double x = epochToX(draggedPosition.dx.toInt());
    final double y = quoteToY(draggedPosition.dy);

    return Point(x: x, y: y);
  }

  /// A method that takes the gesture delta Offset object as parameter
  /// and sets the draggedPosition field to its value.
  void updatePositionWithLocalPositions(
      Offset delta,
      XAxisModel xAxis,
      double Function(double) quoteFromCanvasY,
      double Function(double y) quoteToY,
      {required bool isOtherEndDragged}) {
    final Offset localPosition = Offset(
            xAxis.xFromEpoch(draggedPosition.dx.toInt()),
            quoteToY(draggedPosition.dy)) +
        (isOtherEndDragged ? Offset.zero : delta);

    draggedPosition = Offset(xAxis.epochFromX(localPosition.dx).toDouble(),
        quoteFromCanvasY(localPosition.dy));
  }
}
