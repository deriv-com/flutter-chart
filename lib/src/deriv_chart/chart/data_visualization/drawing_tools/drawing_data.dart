import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';

/// A class that hold drawing data.
class DrawingData {
  /// Initializes
  DrawingData({
    required this.id,
    required this.config,
    required this.drawingParts,
    this.isSelected = true,
  });

  /// Unique id of the current drawing.
  final String id;

  /// Configuration of the current drawing.
  final DrawingToolConfig? config;

  /// Drawing list.
  final List<Drawing> drawingParts;

  /// If the drawing is selected by the user.
  bool isSelected;

  /// Updates configuration.
  DrawingData updateConfig(DrawingToolConfig config) =>
      DrawingData(id: id, config: config, drawingParts: drawingParts);

  /// Updates drawing list.
  DrawingData updateDrawingList(List<Drawing> drawingParts) =>
      DrawingData(id: id, config: config, drawingParts: drawingParts);
}
