import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_creator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_painter.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';

/// A wigdet for encapsulating drawing tools related business logic
class DrawingToolChart extends StatelessWidget {
  /// Creates chart that expands to available space.
  const DrawingToolChart({
    required this.onAddDrawing,
    required this.chartQuoteFromCanvasY,
    required this.chartQuoteToCanvasY,
    required this.onMoveDrawing,
    required this.series,
    required this.clearDrawingToolSelection,
    this.drawings,
    this.selectedDrawingTool,
    Key? key,
  }) : super(key: key);

  /// series of ticks for getting epoch and quote
  final DataSeries<Tick> series;

  /// Existing drawings.
  final List<DrawingData>? drawings;

  /// Callback to pass new drawing to the parent.
  final void Function(Map<String, List<Drawing>> addedDrawing,
      {bool isDrawingFinished}) onAddDrawing;

  /// Callback to pass new drawing to the parent.
  final void Function({bool isDrawingMoved}) onMoveDrawing;

  /// Callback to clean drawing tool selection.
  final VoidCallback clearDrawingToolSelection;

  /// Selected drawing tool.
  final DrawingToolConfig? selectedDrawingTool;

  /// Conversion function for converting quote from chart's canvas' Y position.
  final double Function(double) chartQuoteFromCanvasY;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) chartQuoteToCanvasY;

  /// Sets drawing as selected and unselects the rest of drawings
  void _setIsDrawingSelected(DrawingData drawing) {
    drawing.isSelected = !drawing.isSelected;

    for (final DrawingData data in drawings!) {
      if (data.id != drawing.id) {
        data.isSelected = false;
      }
    }
  }

  /// Removes specific drawing from the list of drawings
  void removeDrawing(String drawingId) {
    drawings!.removeWhere((DrawingData data) => data.id == drawingId);
  }

  @override
  Widget build(BuildContext context) => ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (drawings != null)
              ...drawings!.map((DrawingData drawingData) => DrawingPainter(
                    series: series,
                    drawingData: drawingData,
                    quoteToCanvasY: chartQuoteToCanvasY,
                    quoteFromCanvasY: chartQuoteFromCanvasY,
                    onMoveDrawing: onMoveDrawing,
                    setIsDrawingSelected: _setIsDrawingSelected,
                  )),
            if (selectedDrawingTool != null)
              DrawingCreator(
                onAddDrawing: onAddDrawing,
                selectedDrawingTool: selectedDrawingTool!,
                quoteFromCanvasY: chartQuoteFromCanvasY,
                clearDrawingToolSelection: clearDrawingToolSelection,
                removeDrawing: removeDrawing,
              ),
          ],
        ),
      );
}
