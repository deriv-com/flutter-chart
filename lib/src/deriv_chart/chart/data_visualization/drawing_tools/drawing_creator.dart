import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/line/line_drawing_creator.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';

/// Creates a drawing piece by piece collected on every gesture
/// exists in a widget tree starting from selecting a selectedDrawingTool and
/// until drawing is finished
class DrawingCreator extends StatelessWidget {
  /// Initializes drawing creator area.
  const DrawingCreator({
    required this.onAddDrawing,
    required this.selectedDrawingTool,
    Key? key,
  }) : super(key: key);

  /// Selected drawing tool.
  final DrawingToolConfig selectedDrawingTool;

  /// Callback to pass a newly created drawing to the parent.
  final void Function(Map<String, List<Drawing>> addedDrawing,
      {bool isDrawingFinished}) onAddDrawing;

  @override
  Widget build(BuildContext context) {
    final String drawingToolType = selectedDrawingTool.toJson()['name'];
    switch (drawingToolType) {
      case 'line':
        return LineDrawingCreator(onAddDrawing: onAddDrawing);
      // TODO(maryia-binary): add the rest of drawing tools here
      default:
        return Container();
    }
  }
}
