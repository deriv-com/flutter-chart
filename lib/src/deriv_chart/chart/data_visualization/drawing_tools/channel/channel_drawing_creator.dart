import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/channel/channel_drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_creator.dart';
import 'package:flutter/material.dart';
import '../data_model/drawing_parts.dart';

/// Creates a Channel drawing piece by piece collected on every gesture
/// exists in a widget tree starting from selecting the channel drawing tool
/// and until drawing should be finished.
class ChannelDrawingCreator extends DrawingCreator<ChannelDrawing> {
  /// Initializes the channel drawing creator.
  const ChannelDrawingCreator({
    required OnAddDrawing<ChannelDrawing> onAddDrawing,
    required double Function(double) quoteFromCanvasY,
    required this.clearDrawingToolSelection,
    required this.removeUnfinishedDrawing,
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
  final void Function() removeUnfinishedDrawing;

  /// A flag to show when to stop drawing only for drawings which don't have
  /// fixed number of points like continuous drawing
  final bool shouldStopDrawing;

  @override
  DrawingCreatorState<ChannelDrawing> createState() =>
      _ChannelDrawingCreatorState();
}

class _ChannelDrawingCreatorState extends DrawingCreatorState<ChannelDrawing> {
  @override
  void onTap(TapUpDetails details) {
    super.onTap(details);
    final ChannelDrawingCreator _widget = widget as ChannelDrawingCreator;

    if (isDrawingFinished) {
      return;
    }
    setState(() {
      position = details.localPosition;
      tapCount++;

      if (edgePoints.isEmpty) {
        /// Draw the initial point of the line.
        edgePoints.add(EdgePoint(
          epoch: epochFromX!(position!.dx),
          quote: widget.quoteFromCanvasY(position!.dy),
        ));

        drawingParts.add(ChannelDrawing(
          drawingPart: DrawingParts.marker,
          startEdgePoint: edgePoints.first,
        ));
      } else if (edgePoints.length == 1) {
        edgePoints.add(EdgePoint(
          epoch: epochFromX!(position!.dx),
          quote: widget.quoteFromCanvasY(position!.dy),
        ));

        /// Checks if the initial point and the final point are the same.
        if (edgePoints[1] == edgePoints.first) {
          /// If the initial point and the 2nd point are the same,
          /// remove the drawing and clean the drawing tool selection.
          _widget.removeUnfinishedDrawing();
          _widget.clearDrawingToolSelection();
          return;
        } else {
          /// If the initial point and the final point are not the same,
          /// draw the final point and the whole line.
          drawingParts.addAll(<ChannelDrawing>[
            ChannelDrawing(
              drawingPart: DrawingParts.marker,
              middleEdgePoint: edgePoints[1],
            ),
            ChannelDrawing(
              drawingPart: DrawingParts.line,
              startEdgePoint: edgePoints[0],
              middleEdgePoint: edgePoints[1],
            )
          ]);
        }
      } else if (edgePoints.length == 2) {
        /// Draw final point and the whole line.
        isDrawingFinished = true;
        edgePoints.add(EdgePoint(
          epoch: edgePoints[1].epoch,
          quote: widget.quoteFromCanvasY(position!.dy),
        ));

        /// If the initial point and the final point are not the same,
        /// draw the final point and the whole line.
        drawingParts.addAll(<ChannelDrawing>[
          ChannelDrawing(
            drawingPart: DrawingParts.marker,
            middleEdgePoint: edgePoints[1],
            endEdgePoint: edgePoints[2],
          ),
          ChannelDrawing(
            drawingPart: DrawingParts.line,
            startEdgePoint: edgePoints[0],
            middleEdgePoint: edgePoints[1],
            endEdgePoint: edgePoints[2],
            isDrawingFinished: isDrawingFinished,
          )
        ]);
      }
      widget.onAddDrawing(
        drawingId,
        drawingParts,
        isDrawingFinished: isDrawingFinished,
      );
    });
  }
}
