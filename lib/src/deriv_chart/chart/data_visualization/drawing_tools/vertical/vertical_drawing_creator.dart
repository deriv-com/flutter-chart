import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_creator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:flutter/material.dart';
import './vertical_drawing.dart';

/// Creates a Vertical line drawing
class VerticalDrawingCreator extends DrawingCreator<VerticalDrawing> {
  /// Initializes the vertical drawing creator.
  const VerticalDrawingCreator({
    required OnAddDrawing<VerticalDrawing> onAddDrawing,
    required double Function(double) quoteFromCanvasY,
    Key? key,
  }) : super(
          key: key,
          onAddDrawing: onAddDrawing,
          quoteFromCanvasY: quoteFromCanvasY,
        );

  @override
  DrawingCreatorState<VerticalDrawing> createState() =>
      _VerticalDrawingCreatorState();
}

class _VerticalDrawingCreatorState
    extends DrawingCreatorState<VerticalDrawing> {
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

      drawingParts.add(VerticalDrawing(
        drawingPart: DrawingParts.line,
        edgePoint: edgePoints.first,
      ));

      widget.onAddDrawing(
        drawingId,
        drawingParts,
        isDrawingFinished: isDrawingFinished,
      );
    });
  }
}
