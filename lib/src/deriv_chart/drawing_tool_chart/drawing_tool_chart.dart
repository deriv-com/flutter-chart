import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_tool_widget.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_painter.dart';
import 'package:deriv_chart/src/deriv_chart/drawing_tool_chart/drawing_tools.dart';
import 'package:flutter/material.dart';

/// A wigdet for encapsulating drawing tools related business logic
class DrawingToolChart extends StatelessWidget {
  /// Creates chart that expands to available space.
  const DrawingToolChart({
    required this.chartQuoteFromCanvasY,
    required this.chartQuoteToCanvasY,
    required this.drawingTools,
    Key? key,
  }) : super(key: key);

  /// Conversion function for converting quote from chart's canvas' Y position.
  final double Function(double) chartQuoteFromCanvasY;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) chartQuoteToCanvasY;

  /// Contains drawing tools related data and methods
  final DrawingTools drawingTools;

  /// Sets drawing as selected and unselects the rest of drawings
  /// if any of the drawing is not finished , it selects the unfinished drawing
  void _setIsDrawingSelected(DrawingData drawing) {
    drawing.isSelected = !drawing.isSelected;

    for (final DrawingData data in drawingTools.drawings) {
      if (data.id != drawing.id) {
        data.isSelected = false;
      }
    }
  }

  /// Removes specific drawing from the list of drawings
  void removeDrawing(String drawingId) {
    drawingTools.drawings
        .removeWhere((DrawingData data) => data.id == drawingId);
  }

  @override
  Widget build(BuildContext context) => ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ...drawingTools.drawings
                .map((DrawingData drawingData) => DrawingPainter(
                      drawingData: drawingData,
                      quoteToCanvasY: chartQuoteToCanvasY,
                      quoteFromCanvasY: chartQuoteFromCanvasY,
                      onMoveDrawing: drawingTools.onMoveDrawing,
                      setIsDrawingSelected: _setIsDrawingSelected,
                      selectedDrawingTool: drawingTools.selectedDrawingTool,
                    )),
            if (drawingTools.selectedDrawingTool != null)
              DrawingToolWidget(
                onAddDrawing: drawingTools.onAddDrawing,
                selectedDrawingTool: drawingTools.selectedDrawingTool!,
                quoteFromCanvasY: chartQuoteFromCanvasY,
                clearDrawingToolSelection:
                    drawingTools.clearDrawingToolSelection,
                removeDrawing: removeDrawing,
                shouldStopDrawing: drawingTools.shouldStopDrawing,
              ),
          ],
        ),
      );
}
