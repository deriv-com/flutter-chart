import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';

/// A class that hold drawing data.
class DrawingData {
  /// Initializes
  DrawingData({
    required this.id,
    required this.config,
    required this.drawingParts,
    this.isDrawingFinished = false,
    this.isSelected = true,
    this.series,
  });

  /// Unique id of the current drawing.
  final String id;

  /// Configuration of the current drawing.
  final DrawingToolConfig config;

  /// Series of ticks
  List<Tick>? series;

  /// Drawing list.
  final List<Drawing> drawingParts;

  /// If drawing is finished.
  bool isDrawingFinished;

  /// If the drawing is selected by the user.
  bool isSelected;

  /// Updates configuration.
  DrawingData updateConfig(DrawingToolConfig config) => DrawingData(
        id: id,
        config: config,
        drawingParts: drawingParts,
        isDrawingFinished: isDrawingFinished,
      );

  /// Updates drawing list.
  DrawingData updateDrawingPartList(List<Drawing> drawingParts) =>
      DrawingData(id: id, config: config, drawingParts: drawingParts);

  /// Determines if this [DrawingData] needs to be repainted.
  ///
  /// Returns `true` if any of the [drawingParts] needs to be repainted.
  bool shouldRepaint(
    DrawingData oldDrawingData,
    int leftEpoch,
    int rightEpoch,
    DraggableEdgePoint draggableStartPoint, {
    DraggableEdgePoint? draggableEndPoint,
  }) {
    for (final Drawing drawing in drawingParts) {
      if (drawing.needsRepaint(
        leftEpoch,
        rightEpoch,
        draggableStartPoint,
        draggableEndPoint: draggableEndPoint,
      )) {
        return true;
      }
    }

    return false;
  }
}
