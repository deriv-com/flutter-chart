import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_creator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_painter.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';

/// Interactive chart widget.
class DrawingToolChart extends StatefulWidget {
  /// Creates chart that expands to available space.
  const DrawingToolChart({
    required this.onAddDrawing,
    required this.chartQuoteFromCanvasY,
    required this.chartQuoteToCanvasY,
    this.drawings,
    this.selectedDrawingTool,
    Key? key,
  }) : super(key: key);

  /// Existing drawings.
  final List<DrawingData>? drawings;

  /// Callback to pass new drawing to the parent.
  final void Function(Map<String, List<Drawing>> addedDrawing,
      {bool isDrawingFinished}) onAddDrawing;

  /// Selected drawing tool.
  final DrawingToolConfig? selectedDrawingTool;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) chartQuoteFromCanvasY;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) chartQuoteToCanvasY;

  @override
  State<StatefulWidget> createState() => _DrawingToolChartState();
}

// ignore: prefer_mixin
class _DrawingToolChartState extends State<DrawingToolChart> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (widget.drawings != null)
              ...widget.drawings!
                  .map((DrawingData drawingData) => DrawingPainter(
                        drawingData: drawingData,
                        quoteToCanvasY: widget.chartQuoteToCanvasY,
                      )),
            if (widget.selectedDrawingTool != null)
              DrawingCreator(
                onAddDrawing: widget.onAddDrawing,
                selectedDrawingTool: widget.selectedDrawingTool!,
                quoteFromCanvasY: widget.chartQuoteFromCanvasY,
              ),
          ],
        ),
      );

  @override
  void didUpdateWidget(covariant DrawingToolChart oldWidget) {
    super.didUpdateWidget(oldWidget);
  }
}
