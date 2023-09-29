import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_tool_widget.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_painter.dart';
import 'package:deriv_chart/src/deriv_chart/drawing_tool_chart/drawing_tools.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deriv_chart/src/models/chart_config.dart';

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
  late Repository<DrawingToolConfig> repo;

  /// A method to get the list of drawing data from the repository
  List<DrawingData?> getDrawingData() => repo.items
      .map<DrawingData?>((DrawingToolConfig config) => config.drawingData)
      .toList();

  /// Sets drawing as selected and unselects the rest of drawings
  /// if any of the drawing is not finished , it selects the unfinished drawing
  void _setIsDrawingSelected(DrawingData drawing) {
    setState(() {
      drawing.isSelected = !drawing.isSelected;

      for (final DrawingData? data in getDrawingData()) {
        if (data!.id != drawing.id) {
          data.isSelected = false;
        }
      }
    });
  }

  /// Removes specific drawing from the list of drawings
  void removeUnfinishedDrawing() {
    final List<DrawingData?> unfinishedDrawings = getDrawingData()
        .where((DrawingData? data) => !data!.isDrawingFinished)
        .toList();
    repo.removeAt(getDrawingData().indexOf(unfinishedDrawings.first));
  }

  @override
  Widget build(BuildContext context) {
    repo = context.watch<Repository<DrawingToolConfig>>();

    final List<DrawingToolConfig> configs = repo.items.toList();

    final List<DrawingData?> drawings = configs
        .map<DrawingData?>((DrawingToolConfig config) => config.drawingData)
        .toList();

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (drawings.isNotEmpty)
            ...drawings.map((DrawingData? drawingData) => DrawingPainter(
                  key: ValueKey<String>(drawingData!.id),
                  drawingData: drawingData,
                  drawingConfig: configs
                      .where((DrawingToolConfig config) =>
                          config.configId == drawingData.id)
                      .firstOrNull,
                  quoteToCanvasY: widget.chartQuoteToCanvasY,
                  quoteFromCanvasY: widget.chartQuoteFromCanvasY,
                  onMoveDrawing: widget.drawingTools.onMoveDrawing,
                  setIsDrawingSelected: _setIsDrawingSelected,
                  selectedDrawingTool: widget.drawingTools.selectedDrawingTool,
                  series: widget.series,
                )),
          if (widget.drawingTools.selectedDrawingTool != null)
            DrawingToolWidget(
              onAddDrawing: widget.drawingTools.onAddDrawing,
              selectedDrawingTool: widget.drawingTools.selectedDrawingTool!,
              quoteFromCanvasY: widget.chartQuoteFromCanvasY,
              chartConfig: context.watch<ChartConfig>(),
              clearDrawingToolSelection:
                  widget.drawingTools.clearDrawingToolSelection,
              series: widget.series,
              removeUnfinishedDrawing: removeUnfinishedDrawing,
              shouldStopDrawing: widget.drawingTools.shouldStopDrawing,
            ),
        ],
      ),
    );
  }
}
