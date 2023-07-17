import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/creator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/line/line_drawing.dart';
import 'package:flutter/material.dart';

/// Creates a Line drawing piece by piece collected on every gesture
/// exists in a widget tree starting from selecting a line drawing tool and
/// until drawing is finished
class LineDrawingCreator extends Creator<LineDrawing> {
  /// Initializes the line drawing creator.
  const LineDrawingCreator({
    required OnAddDrawing<LineDrawing> onAddDrawing,
    required double Function(double) quoteFromCanvasY,
    required this.clearDrawingToolSelection,
    required this.removeDrawing,
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

  @override
  CreatorState<LineDrawing> createState() => _LineDrawingCreatorState();
}

class _LineDrawingCreatorState extends CreatorState<LineDrawing> {
  /// If drawing has been started.
  bool _isPenDown = false;

  @override
  void onTap(TapUpDetails details) {
    final LineDrawingCreator _widget = widget as LineDrawingCreator;

    if (isDrawingFinished) {
      return;
    }
    setState(() {
      position = details.localPosition;
      tapCount++;

      if (!_isPenDown) {
        /// Draw the initial point of the line.
        edgePoints.add(EdgePoint(
          epoch: epochFromX!(position!.dx),
          quote: widget.quoteFromCanvasY(position!.dy),
        ));
        _isPenDown = true;
        drawingId = 'line_${edgePoints.first.epoch}';

        drawingParts.add(LineDrawing(
          drawingPart: DrawingParts.marker,
          startEdgePoint: edgePoints.first,
        ));
      } else if (!isDrawingFinished) {
        /// Draw final point and the whole line.
        _isPenDown = false;
        isDrawingFinished = true;
        final int _currentTap = tapCount - 1;
        final int _previousTap = tapCount - 2;

        edgePoints.add(EdgePoint(
          epoch: epochFromX!(position!.dx),
          quote: widget.quoteFromCanvasY(position!.dy),
        ));

        /// Checks if the initial point and the final point are the same.
        if (Offset(edgePoints[1].epoch.toDouble(),
                edgePoints[1].quote.toDouble()) ==
            Offset(edgePoints.first.epoch.toDouble(),
                edgePoints.first.quote.toDouble())) {
          /// If the initial point and the 2nd point are the same,
          /// remove the drawing and clean the drawing tool selection.
          _widget.removeDrawing(drawingId);
          _widget.clearDrawingToolSelection();
          return;
        } else {
          /// If the initial point and the final point are not the same,
          /// draw the final point and the whole line.
          drawingParts.addAll(<LineDrawing>[
            LineDrawing(
              drawingPart: DrawingParts.marker,
              endEdgePoint: edgePoints[_currentTap],
            ),
            LineDrawing(
              drawingPart: DrawingParts.line,
              startEdgePoint: edgePoints[_previousTap],
              endEdgePoint: edgePoints[_currentTap],
              exceedStart: true,
              exceedEnd: true,
            )
          ]);
        }
      }
      widget.onAddDrawing(
        <String, List<LineDrawing>>{drawingId: drawingParts},
        isDrawingFinished: isDrawingFinished,
      );
    });
  }
}