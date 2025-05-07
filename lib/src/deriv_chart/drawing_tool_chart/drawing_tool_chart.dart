import 'package:collection/collection.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_painter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A widget for encapsulating drawing tools related business logic
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
    final ChartConfig chartConfig = context.watch<ChartConfig>();

    return ClipRect(
      child: RepaintBoundary(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (drawings.isNotEmpty)
              ...drawings.mapIndexed(
                (int index, DrawingData? drawingData) => DrawingPainter(
                  key: ValueKey<String>(
                    '''${drawingData?.id}_${context.watch<ChartConfig>().granularity}''',
                  ),
                  drawingData: drawingData,
                  quoteToCanvasY: widget.chartQuoteToCanvasY,
                  onMouseEnter: () => widget.drawingTools.onMouseEnter(index),
                  onMouseExit: () => widget.drawingTools.onMouseExit(index),
                  quoteFromCanvasY: widget.chartQuoteFromCanvasY,
                  isDrawingMoving: widget.drawingTools.isDrawingMoving,
                  onMoveDrawing: widget.drawingTools.onMoveDrawing,
                  setIsDrawingSelected: _setIsDrawingSelected,
                  selectedDrawingTool: widget.drawingTools.selectedDrawingTool,
                  series: widget.series,
                  chartConfig: chartConfig,
                ),
              ),
            if (widget.drawingTools.selectedDrawingTool != null)
              DrawingToolWidget(
                onAddDrawing: widget.drawingTools.onAddDrawing,
                selectedDrawingTool: widget.drawingTools.selectedDrawingTool!,
                quoteFromCanvasY: widget.chartQuoteFromCanvasY,
                chartConfig: chartConfig,
                clearDrawingToolSelection:
                    widget.drawingTools.clearDrawingToolSelection,
                series: widget.series,
                removeUnfinishedDrawing: removeUnfinishedDrawing,
                shouldStopDrawing: widget.drawingTools.shouldStopDrawing,
              ),
          ],
        ),
      ),
    );
  }
}
