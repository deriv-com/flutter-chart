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

  @override
  void onTap(TapUpDetails details) {
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

        drawingParts.add(TrendDrawing(
          epochFromX: epochFromX,
          drawingPart: DrawingParts.marker,
          startingEpoch: edgePoints.first.epoch,
          startingQuote: edgePoints.first.quote,
        ));
      } else if (!isDrawingFinished) {
        edgePoints.add(EdgePoint(
            epoch: epochFromX!(position!.dx),
            quote: widget.quoteFromCanvasY(position!.dy)));

        /// Draw final drawing
        _isPenDown = false;
        isDrawingFinished = true;

        drawingParts
          ..removeAt(0)
          ..add(
            TrendDrawing(
              epochFromX: epochFromX,
              drawingPart: DrawingParts.rectangle,
              startingEpoch: edgePoints.first.epoch,
              startingQuote: edgePoints.first.quote,
              endingEpoch: edgePoints[1].epoch,
              endingQuote: edgePoints[1].quote,
            ),
          )
          ..add(
            TrendDrawing(
              epochFromX: epochFromX,
              drawingPart: DrawingParts.line,
              startingEpoch: edgePoints.first.epoch,
              startingQuote: edgePoints.first.quote,
              endingEpoch: edgePoints[1].epoch,
              endingQuote: edgePoints[1].quote,
            ),
          )
          ..add(TrendDrawing(
            epochFromX: epochFromX,
            drawingPart: DrawingParts.marker,
            startingEpoch: edgePoints.first.epoch,
            startingQuote: edgePoints.first.quote,
            endingEpoch: edgePoints[1].epoch,
            endingQuote: edgePoints[1].quote,
          ));
      }

      widget.onAddDrawing(
        <String, List<TrendDrawing>>{drawingId: drawingParts},
        isDrawingFinished: isDrawingFinished,
      );
    });
  }
}
