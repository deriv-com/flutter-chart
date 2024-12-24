import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/channel/channel_drawing_creator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/continuous/continuous_drawing_creator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/horizontal/horizontal_drawing_creator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/fibfan/fibfan_drawing_creator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/line/line_drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/line/line_drawing_mobile.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/line/line_drawing_creator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/rectangle/rectangle_drawing_creator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/ray/ray_drawing_creator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/trend/trend_drawing_creator.dart';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/vertical/vertical_drawing_creator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
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
    required this.removeUnfinishedDrawing,
    required this.chartConfig,
    required this.series,
    this.shouldStopDrawing,
    Key? key,
  }) : super(key: key);

  /// ChartConfig for getting pipsize
  final ChartConfig chartConfig;

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
    List<EdgePoint>? edgePoints,
  }) onAddDrawing;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteFromCanvasY;

  /// Callback to clean drawing tool selection.
  final VoidCallback clearDrawingToolSelection;

  /// Callback to remove unfinished drawing from the list of drawings.
  final VoidCallback removeUnfinishedDrawing;

  /// A flag to show when to stop drawing only for drawings which don't have
  /// fixed number of points like continuous drawing
  final bool? shouldStopDrawing;

  @override
  Widget build(BuildContext context) {
    // TODO(bahar-deriv): Deligate the creation of drawing to the specific
    // drawing tool config
    final String drawingToolType = selectedDrawingTool.toJson()['name'];

    switch (drawingToolType) {
      case 'dt_channel':
        return ChannelDrawingCreator(
          onAddDrawing: onAddDrawing,
          quoteFromCanvasY: quoteFromCanvasY,
          clearDrawingToolSelection: clearDrawingToolSelection,
          removeUnfinishedDrawing: removeUnfinishedDrawing,
          shouldStopDrawing: shouldStopDrawing!,
        );
      case 'dt_continuous':
        return ContinuousDrawingCreator(
          onAddDrawing: onAddDrawing,
          quoteFromCanvasY: quoteFromCanvasY,
          clearDrawingToolSelection: clearDrawingToolSelection,
          removeUnfinishedDrawing: removeUnfinishedDrawing,
          shouldStopDrawing: shouldStopDrawing!,
        );
      case 'dt_fibfan':
        return FibfanDrawingCreator(
          onAddDrawing: onAddDrawing,
          quoteFromCanvasY: quoteFromCanvasY,
          clearDrawingToolSelection: clearDrawingToolSelection,
          removeUnfinishedDrawing: removeUnfinishedDrawing,
        );
      case 'dt_horizontal':
        return HorizontalDrawingCreator(
          onAddDrawing: onAddDrawing,
          quoteFromCanvasY: quoteFromCanvasY,
          chartConfig: chartConfig,
        );
      case 'dt_line':
        return LineDrawingCreator(
          onAddDrawing: onAddDrawing,
          quoteFromCanvasY: quoteFromCanvasY,
          clearDrawingToolSelection: clearDrawingToolSelection,
          removeUnfinishedDrawing: removeUnfinishedDrawing,
          createLineDrawing: ({
            required DrawingParts drawingPart,
            EdgePoint startEdgePoint = const EdgePoint(),
            EdgePoint endEdgePoint = const EdgePoint(),
            bool exceedStart = false,
            bool exceedEnd = false,
          }) =>
              LineDrawing(
                  drawingPart: drawingPart,
                  startEdgePoint: startEdgePoint,
                  endEdgePoint: endEdgePoint,
                  exceedStart: exceedStart,
                  exceedEnd: exceedEnd),
        );
      case 'dt_line_mobile':
        return LineDrawingCreator(
          onAddDrawing: onAddDrawing,
          quoteFromCanvasY: quoteFromCanvasY,
          clearDrawingToolSelection: clearDrawingToolSelection,
          removeUnfinishedDrawing: removeUnfinishedDrawing,
          createLineDrawing: ({
            required DrawingParts drawingPart,
            EdgePoint startEdgePoint = const EdgePoint(),
            EdgePoint endEdgePoint = const EdgePoint(),
            bool exceedStart = false,
            bool exceedEnd = false,
          }) =>
              LineDrawingMobile(
                  drawingPart: drawingPart,
                  startEdgePoint: startEdgePoint,
                  endEdgePoint: endEdgePoint,
                  exceedStart: exceedStart,
                  exceedEnd: exceedEnd),
        );
      case 'dt_ray':
        return RayDrawingCreator(
          onAddDrawing: onAddDrawing,
          quoteFromCanvasY: quoteFromCanvasY,
          clearDrawingToolSelection: clearDrawingToolSelection,
          removeUnfinishedDrawing: removeUnfinishedDrawing,
        );
      case 'dt_rectangle':
        return RectangleDrawingCreator(
          onAddDrawing: onAddDrawing,
          quoteFromCanvasY: quoteFromCanvasY,
          clearDrawingToolSelection: clearDrawingToolSelection,
          removeUnfinishedDrawing: removeUnfinishedDrawing,
        );
      case 'dt_trend':
        return TrendDrawingCreator(
          onAddDrawing: onAddDrawing,
          clearDrawingToolSelection: clearDrawingToolSelection,
          quoteFromCanvasY: quoteFromCanvasY,
          removeUnfinishedDrawing: removeUnfinishedDrawing,
          series: series,
        );
      case 'dt_vertical':
        return VerticalDrawingCreator(
          onAddDrawing: onAddDrawing,
          quoteFromCanvasY: quoteFromCanvasY,
          chartConfig: chartConfig,
        );

      // TODO(maryia-binary): add the rest of drawing tools here
      default:
        return Container();
    }
  }
}
