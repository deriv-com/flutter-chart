import 'dart:math';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/creator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/trend/trend_drawing.dart';
import 'package:flutter/material.dart';
import '../data_model/drawing_parts.dart';

/// Creates a Trend drawing right after selecting the trend drawing tool
/// and until drawing is finished
class TrendDrawingCreator extends Creator<TrendDrawing> {
  /// Initializes the trend drawing creator.
  const TrendDrawingCreator({
    required void Function(
      Map<String, List<TrendDrawing>>, {
      bool isDrawingFinished,
      bool isInfiniteDrawing,
    }) onAddDrawing,
    required double Function(double) quoteFromCanvasY,
    required this.cleanDrawingToolSelection,
    required this.removeDrawing,
    Key? key,
  }) : super(
            key: key,
            onAddDrawing: onAddDrawing,
            quoteFromCanvasY: quoteFromCanvasY);

  /// Callback to clean drawing tool selection.
  final VoidCallback cleanDrawingToolSelection;

  /// Callback to remove specific drawing from the list of drawings.
  final void Function(String drawingId) removeDrawing;

  @override
  CreatorState<TrendDrawing> createState() => _TrendDrawingCreatorState();
}

class _TrendDrawingCreatorState extends CreatorState<TrendDrawing> {
  // /// If drawing has been started.
  bool _isPenDown = false;

  /// Stores coordinate of first point on the graph
  Offset? firstPointOnGraph;

  void getFirstClickPoint(int x, double y) {
    // the actual first point coord
    firstPointOnGraph = Offset(x.toDouble(), y);
  }

  @override
  void onTap(TapUpDetails details) {
    final TrendDrawingCreator _widget = widget as TrendDrawingCreator;

    if (isDrawingFinished) {
      return;
    }
    setState(() {
      position = details.localPosition;
      if (!_isPenDown) {
        /// Draw the initial point of the line.
        edgePoints.add(EdgePoint(
            epoch: epochFromX!(position!.dx),
            quote: widget.quoteFromCanvasY(position!.dy)));

        _isPenDown = true;

        drawingId = 'trend_${edgePoints.first.epoch}';

        drawingParts.add(
          TrendDrawing(
            epochFromX: epochFromX,
            drawingPart: DrawingParts.marker,
            startingEdgePoint: edgePoints.first,
            getFirstActualClick: getFirstClickPoint,
          ),
        );
      } else if (!isDrawingFinished) {
        edgePoints.add(EdgePoint(
            epoch: epochFromX!(position!.dx),
            quote: widget.quoteFromCanvasY(position!.dy)));

        /// Draw final drawing
        _isPenDown = false;
        isDrawingFinished = true;

        // When the second point is on the same y
        //coordinate as the first point
        if ((firstPointOnGraph!.dx - edgePoints[1].epoch).abs() <= 200) {
          /// remove the drawing and clean the drawing tool selection.
          _widget.removeDrawing(drawingId);
          _widget.cleanDrawingToolSelection();
          return;
        }

        drawingParts
          ..removeAt(0)
          ..addAll(<TrendDrawing>[
            TrendDrawing(
                epochFromX: epochFromX,
                drawingPart: DrawingParts.rectangle,
                startingEdgePoint: edgePoints.first,
                endingEdgePoint: edgePoints[1]),
            TrendDrawing(
                epochFromX: epochFromX,
                drawingPart: DrawingParts.line,
                startingEdgePoint: edgePoints.first,
                endingEdgePoint: edgePoints[1]),
            TrendDrawing(
                epochFromX: epochFromX,
                drawingPart: DrawingParts.marker,
                startingEdgePoint: edgePoints.first,
                endingEdgePoint: edgePoints[1])
          ]);
      }

      widget.onAddDrawing(
        <String, List<TrendDrawing>>{drawingId: drawingParts},
        isDrawingFinished: isDrawingFinished,
      );
    });
  }
}
