import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/continuous/continuous_drawing_creator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/fibfan/fibfan_drawing_creator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/line/line_drawing_creator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/trend/trend_drawing_creator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/vertical/vertical_drawing_creator.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';

/// The class acts as a bridge between the selected drawing tool and the
/// drawing creation process, delegating the specific creation logic to the
/// corresponding drawing tool configurations.
class DrawingToolWidget extends StatelessWidget {
  /// Initializes drawing creator area.
  const DrawingToolWidget({
    required this.onAddDrawing,
    required this.selectedDrawingTool,
    required this.quoteFromCanvasY,
    required this.clearDrawingToolSelection,
    required this.removeDrawing,
    required this.series,
    this.shouldStopDrawing,
    Key? key,
  }) : super(key: key);

  /// Selected drawing tool.
  final DrawingToolConfig selectedDrawingTool;

  /// Series of tick
  final DataSeries<Tick> series;

  /// Callback to pass a newly created drawing to the parent.
  final void Function(
    String drawingId,
    List<Drawing> drawingParts, {
    bool isDrawingFinished,
    bool isInfiniteDrawing,
  }) onAddDrawing;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteFromCanvasY;

  /// Callback to clean drawing tool selection.
  final VoidCallback clearDrawingToolSelection;

  /// Callback to remove specific drawing from the list of drawings.
  final void Function(String drawingId) removeDrawing;

  /// A flag to show when to stop drawing only for drawings which don't have
  /// fixed number of points like continuous drawing
  final bool? shouldStopDrawing;

  @override
  Widget build(BuildContext context) {
    // TODO(bahar-deriv): Deligate the creation of drawing to the specific
    // drawing tool config
    final String drawingToolType = selectedDrawingTool.toJson()['name'];

    switch (drawingToolType) {
      case 'dt_continuous':
        return ContinuousDrawingCreator(
          onAddDrawing: onAddDrawing,
          quoteFromCanvasY: quoteFromCanvasY,
          clearDrawingToolSelection: clearDrawingToolSelection,
          removeDrawing: removeDrawing,
          shouldStopDrawing: shouldStopDrawing!,
        );
      case 'dt_fibfan':
        return FibfanDrawingCreator(
          onAddDrawing: onAddDrawing,
          quoteFromCanvasY: quoteFromCanvasY,
          clearDrawingToolSelection: clearDrawingToolSelection,
          removeDrawing: removeDrawing,
        );
      case 'dt_line':
        return LineDrawingCreator(
          onAddDrawing: onAddDrawing,
          quoteFromCanvasY: quoteFromCanvasY,
          clearDrawingToolSelection: clearDrawingToolSelection,
          removeDrawing: removeDrawing,
        );
      case 'dt_vertical':
        return VerticalDrawingCreator(
          onAddDrawing: onAddDrawing,
          quoteFromCanvasY: quoteFromCanvasY,
        );
      case 'dt_trend':
        return TrendDrawingCreator(
          onAddDrawing: onAddDrawing,
          clearDrawingToolSelection: clearDrawingToolSelection,
          quoteFromCanvasY: quoteFromCanvasY,
          removeDrawing: removeDrawing,
          series: series,
        );

      // TODO(maryia-binary): add the rest of drawing tools here
      default:
        return Container();
    }
  }
}
