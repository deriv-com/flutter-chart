import 'dart:ui';

///A class that holds draggable edge point data
class DraggableEdgePoint {
  /// Represents whether the edge point is currently being dragged or not
  bool isDragged = false;

  /// Holds the current position of the edge point when it is being dragged.
  Offset draggedPosition = Offset.zero;

  /// A callback method that takes the gesture delta Offset object as parameter
  /// and sets the draggedPosition field to its value.
  void updatePosition(Offset newPosition) {
    draggedPosition = newPosition;
  }

  ///A callback method that takes a boolean value as a parameter
  ///and sets the isDragged field to its value.
  void setIsEdgeDragged({required bool isEdgeDragged}) {
    isDragged = isEdgeDragged;
  }
}
