import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_tool_widget.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_painter.dart';
import 'package:deriv_chart/src/deriv_chart/drawing_tool_chart/drawing_tools.dart';
import 'package:flutter/material.dart';

/// A wigdet for encapsulating drawing tools related business logic
class DrawingToolChart extends StatefulWidget {
  /// Creates chart that expands to available space.
  const DrawingToolChart({
    required this.chartQuoteFromCanvasY,
    required this.chartQuoteToCanvasY,
    required this.drawingTools,
    required this.series,
    Key? key,
  }) : super(key: key);

  /// Series of tick
  final DataSeries<Tick> series;

  /// Conversion function for converting quote from chart's canvas' Y position.
  final double Function(double) chartQuoteFromCanvasY;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) chartQuoteToCanvasY;

  /// Contains drawing tools related data and methods
  final DrawingTools drawingTools;

  @override
  State<DrawingToolChart> createState() => _DrawingToolChartState();
}

class _DrawingToolChartState extends State<DrawingToolChart> {
  /// Sets drawing as selected and unselects the rest of drawings
  void _setIsDrawingSelected(DrawingData drawing) {
    drawing.isSelected = !drawing.isSelected;

    for (final DrawingData data in widget.drawingTools.drawings) {
      if (data.id != drawing.id) {
        data.isSelected = false;
      }
    }
  }

  /// Removes specific drawing from the list of drawings
  void removeDrawing(String drawingId) {
    widget.drawingTools.drawings
        .removeWhere((DrawingData data) => data.id == drawingId);
  }

  @override
  void didUpdateWidget(DrawingToolChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final DrawingData data in widget.drawingTools.drawings) {
      data.series = widget.series.entries;
    }
  }

  @override
  Widget build(BuildContext context) => ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ...widget.drawingTools.drawings
                .map((DrawingData drawingData) => DrawingPainter(
                      drawingData: drawingData,
                      quoteToCanvasY: widget.chartQuoteToCanvasY,
                      quoteFromCanvasY: widget.chartQuoteFromCanvasY,
                      onMoveDrawing: widget.drawingTools.onMoveDrawing,
                      setIsDrawingSelected: _setIsDrawingSelected,
                      selectedDrawingTool:
                          widget.drawingTools.selectedDrawingTool,
                    )),
            if (widget.drawingTools.selectedDrawingTool != null)
              DrawingToolWidget(
                onAddDrawing: widget.drawingTools.onAddDrawing,
                selectedDrawingTool: widget.drawingTools.selectedDrawingTool!,
                quoteFromCanvasY: widget.chartQuoteFromCanvasY,
                clearDrawingToolSelection:
                    widget.drawingTools.clearDrawingToolSelection,
                series: widget.series,
                removeDrawing: removeDrawing,
                shouldStopDrawing: widget.drawingTools.shouldStopDrawing,
              ),
          ],
        ),
      );
}
