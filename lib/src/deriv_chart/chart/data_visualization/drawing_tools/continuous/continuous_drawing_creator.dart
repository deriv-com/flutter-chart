import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/creator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/line/line_drawing.dart';
import 'package:flutter/material.dart';
import '../data_model/drawing_parts.dart';

/// Creates a Continuous drawing piece by piece collected on every gesture
/// exists in a widget tree starting from selecting a continuous drawing tool
/// and until drawing should be finished.
class ContinuousDrawingCreator extends Creator<LineDrawing> {
  /// Initializes the continuous drawing creator.
  const ContinuousDrawingCreator({
    required OnAddDrawing<LineDrawing> onAddDrawing,
    required double Function(double) quoteFromCanvasY,
    required this.clearDrawingToolSelection,
    required this.removeDrawing,
    required this.shouldStopDrawing,
    Key? key,
  }) : super(
          key: key,
          onAddDrawing: onAddDrawing,
          quoteFromCanvasY: quoteFromCanvasY,
        );

  /// Callback to clean drawing tool selection.
  final VoidCallback clearDrawingToolSelection;

  /// Callback to remove specific drawing from the list of drawings.
  final void Function(String drawingId) removeDrawing;

  /// A flag to show when to stop drawing only for drawings which don't have
  /// fixed number of points like continuous drawing
  final bool shouldStopDrawing;

  @override
  CreatorState<LineDrawing> createState() => _ContinuousDrawingCreatorState();
}

class _ContinuousDrawingCreatorState extends CreatorState<LineDrawing> {
  @override
  void onTap(TapUpDetails details) {
    final ContinuousDrawingCreator _widget = widget as ContinuousDrawingCreator;

    if (_widget.shouldStopDrawing) {
      return;
    } else {
      isDrawingFinished = false;
    }
    setState(() {
      position = details.localPosition;
      tapCount++;
      final int currentTap = tapCount - 1;
      final int previousTap = tapCount - 2;

      if (edgePoints.isEmpty) {
        /// Draw the initial point of the continuous.
        edgePoints.add(EdgePoint(
          epoch: epochFromX!(position!.dx),
          quote: widget.quoteFromCanvasY(position!.dy),
        ));

        drawingParts.add(LineDrawing(
          drawingPart: DrawingParts.marker,
          startEdgePoint: edgePoints.first,
        ));
      } else if (!isDrawingFinished) {
        /// Draw other points and the whole continuous drawing.

        isDrawingFinished = true;

        edgePoints.add(EdgePoint(
          epoch: epochFromX!(position!.dx),
          quote: widget.quoteFromCanvasY(position!.dy),
        ));

        /// Checks if the initial point and the 2nd points are the same.
        if (edgePoints[1] == edgePoints.first) {
          /// If the initial point and the 2nd point are the same,
          /// remove the drawing and clean the drawing tool selection.
          _widget.removeDrawing(drawingId);
          _widget.clearDrawingToolSelection();
          return;
        } else {
          /// If the initial point and the final point are not the same,
          /// draw the final point and the whole drawing.
          if (tapCount > 2) {
            drawingParts = <LineDrawing>[];

            drawingParts.add(LineDrawing(
              drawingPart: DrawingParts.marker,
              startEdgePoint: edgePoints[previousTap],
            ));
          }
          drawingParts.addAll(<LineDrawing>[
            LineDrawing(
              drawingPart: DrawingParts.marker,
              endEdgePoint: edgePoints[currentTap],
            ),
            LineDrawing(
              drawingPart: DrawingParts.line,
              startEdgePoint: edgePoints[previousTap],
              endEdgePoint: edgePoints[currentTap],
            )
          ]);
        }
      }
      drawingId = 'continuous_${edgePoints[currentTap].epoch}';

      widget.onAddDrawing(
        drawingId,
        drawingParts,
        isDrawingFinished: isDrawingFinished,
        isInfiniteDrawing: true,
      );
    });
  }
}
