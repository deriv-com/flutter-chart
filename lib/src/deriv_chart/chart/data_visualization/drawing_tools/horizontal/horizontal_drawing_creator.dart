import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_creator.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:flutter/material.dart';
import './horizontal_drawing.dart';

/// Creates a Horizontal line drawing
class HorizontalDrawingCreator extends DrawingCreator<HorizontalDrawing> {
  /// Initializes the horizontal drawing creator.
  const HorizontalDrawingCreator({
    required OnAddDrawing<HorizontalDrawing> onAddDrawing,
    required double Function(double) quoteFromCanvasY,
    required ChartConfig chartConfig,
    Key? key,
  }) : super(
          key: key,
          onAddDrawing: onAddDrawing,
          quoteFromCanvasY: quoteFromCanvasY,
          chartConfig: chartConfig,
        );

  @override
  DrawingCreatorState<HorizontalDrawing> createState() =>
      _HorizontalDrawingCreatorState();
}

class _HorizontalDrawingCreatorState
    extends DrawingCreatorState<HorizontalDrawing> {
  @override
  void onTap(TapUpDetails details) {
    super.onTap(details);
    if (isDrawingFinished) {
      return;
    }
    setState(() {
      position = details.localPosition;

      edgePoints.add(EdgePoint(
        epoch: epochFromX!(position!.dx),
        quote: widget.quoteFromCanvasY(position!.dy),
      ));

      isDrawingFinished = true;

      drawingParts.add(HorizontalDrawing(
        drawingPart: DrawingParts.line,
        edgePoint: edgePoints.first,
        chartConfig: widget.chartConfig,
      ));

      widget.onAddDrawing(
        drawingId,
        drawingParts,
        isDrawingFinished: isDrawingFinished,
        edgePoints: <EdgePoint>[...edgePoints],
      );
    });
  }
}
