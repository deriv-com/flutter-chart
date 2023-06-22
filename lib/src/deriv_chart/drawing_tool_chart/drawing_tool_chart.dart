import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_creator.dart';
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
    required this.series,
    Key? key,
  }) : super(key: key);

  /// series of ticks for getting epoch and quote
  final DataSeries<Tick> series;

  /// Conversion function for converting quote from chart's canvas' Y position.
  final double Function(double) chartQuoteFromCanvasY;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) chartQuoteToCanvasY;

  /// Contains drawing tools related data and methods
  final DrawingTools drawingTools;

  /// Sets drawing as selected and unselects the rest of drawings
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
                      series: series,
                      drawingData: drawingData,
                      quoteToCanvasY: chartQuoteToCanvasY,
                      quoteFromCanvasY: chartQuoteFromCanvasY,
                      onMoveDrawing: drawingTools.onMoveDrawing,
                      setIsDrawingSelected: _setIsDrawingSelected,
                    )),
            if (drawingTools.selectedDrawingTool != null)
              DrawingCreator(
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
