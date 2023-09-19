import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:json_annotation/json_annotation.dart';

part 'drawing_data.g.dart';

/// A class that hold drawing data.
@JsonSerializable()
class DrawingData {
  /// Initializes
  DrawingData({
    required this.id,
    required this.drawingParts,
    this.isDrawingFinished = false,
    this.isSelected = true,
  });

  /// Initializes from JSON.
  factory DrawingData.fromJson(Map<String, dynamic> json) =>
      _$DrawingDataFromJson(json);

  /// Serialization to JSON. Serves as value in key-value storage.
  Map<String, dynamic> toJson() => _$DrawingDataToJson(this);

  /// Unique id of the current drawing.
  final String id;

  /// Drawing list.
  final List<Drawing> drawingParts;

  /// If drawing is finished.
  bool isDrawingFinished;

  /// If the drawing is selected by the user.
  bool isSelected;

  /// Determines if this [DrawingData] needs to be repainted.
  /// Returns `true` if any of the [drawingParts] needs to be repainted.
  bool shouldRepaint(
    DrawingData oldDrawingData,
    int leftEpoch,
    int rightEpoch,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableMiddlePoint,
    DraggableEdgePoint? draggableEndPoint,
  }) {
    for (final Drawing drawing in drawingParts) {
      if (drawing.needsRepaint(
        leftEpoch,
        rightEpoch,
        draggableStartPoint,
        draggableMiddlePoint: draggableMiddlePoint,
        draggableEndPoint: draggableEndPoint,
      )) {
        return true;
      }
    }

    return false;
  }
}
