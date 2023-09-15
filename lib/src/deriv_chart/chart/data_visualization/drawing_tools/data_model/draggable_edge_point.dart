import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'draggable_edge_point.g.dart';

/// A class that holds draggable edge point data.
/// Draggable edge points are part of the drawings which added by user clicks
/// And we want to hanle difftent types of drag events on them.
/// For example with dots are draggable edge points for the line
/// ⎯⎯⚪️⎯⎯⎯⚪️⎯⎯
@JsonSerializable()
class DraggableEdgePoint extends EdgePoint {
  /// Initializes
  DraggableEdgePoint({
    int epoch = 0,
    double quote = 0,
    this.isDrawingDragged = false,
    this.isDragged = false,
  }) : super(epoch: epoch, quote: quote);

  /// Initializes from JSON.
  factory DraggableEdgePoint.fromJson(Map<String, dynamic> map) =>
      _$DraggableEdgePointFromJson(map);

  @override
  Map<String, dynamic> toJson() => _$DraggableEdgePointToJson(this);

  /// Represents whether the whole drawing is currently being dragged or not
  final bool isDrawingDragged;

  /// Represents whether the edge point is currently being dragged or not
  final bool isDragged;

  /// Holds the current position of the edge point when it is being dragged.
  Offset _draggedPosition = Offset.zero;

  /// Updated position of the edge point when it is being dragged.
  ///
  /// This would be obsolete when we keep [epoch] and [quote] fields updated
  /// with user's dragging. And we can use them instead of this field.
  Offset get draggedPosition => _draggedPosition;

  /// A callback method that takes the relative x and y positions as parameter,
  /// sets the draggedPosition field to its value and return epoch and quote
  /// values.
  Point updatePosition(
    int epoch,
    double quote,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
  ) {
    final Offset oldPosition = Offset(epoch.toDouble(), quote);
    _draggedPosition = isDrawingDragged ? _draggedPosition : oldPosition;

    final double x = epochToX(_draggedPosition.dx.toInt());
    final double y = quoteToY(_draggedPosition.dy);

    return Point(x: x, y: y);
  }

  /// A method that takes the gesture delta Offset object as parameter
  /// and sets the draggedPosition field to its value.
  void updatePositionWithLocalPositions(
    Offset delta,
    XAxisModel xAxis,
    double Function(double) quoteFromCanvasY,
    double Function(double y) quoteToY, {
    required bool isOtherEndDragged,
  }) {
    final Offset localPosition = Offset(
            xAxis.xFromEpoch(_draggedPosition.dx.toInt()),
            quoteToY(_draggedPosition.dy)) +
        (isOtherEndDragged ? Offset.zero : delta);

    _draggedPosition = Offset(xAxis.epochFromX(localPosition.dx).toDouble(),
        quoteFromCanvasY(localPosition.dy));
  }

  /// Returns the current position of the edge point when it is being dragged.
  EdgePoint getEdgePoint() => EdgePoint(
        epoch: _draggedPosition.dx.toInt(),
        quote: _draggedPosition.dy,
      );

  /// Creates a copy of this object.
  DraggableEdgePoint copyWith({
    int? epoch,
    double? quote,
    bool? isDrawingDragged,
    bool? isDragged,
  }) =>
      DraggableEdgePoint(
        epoch: epoch ?? this.epoch,
        quote: quote ?? this.quote,
        isDrawingDragged: isDrawingDragged ?? this.isDrawingDragged,
        isDragged: isDragged ?? this.isDragged,
      ).._draggedPosition = _draggedPosition;
}
