import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_creator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/ray/ray_line_drawing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

/// Creates a Ray drawing piece by piece collected on every gesture
/// exists in a widget tree starting from selecting a line drawing tool and
/// until drawing is finished
class RayDrawingCreator extends DrawingCreator<RayLineDrawing> {
  /// Initializes the line drawing creator.
  const RayDrawingCreator({
    required OnAddDrawing<RayLineDrawing> onAddDrawing,
    required double Function(double) quoteFromCanvasY,
    required this.clearDrawingToolSelection,
    required this.removeUnfinishedDrawing,
    Key? key,
  }) : super(
          key: key,
          onAddDrawing: onAddDrawing,
          quoteFromCanvasY: quoteFromCanvasY,
        );

  /// Callback to clean drawing tool selection.
  final VoidCallback clearDrawingToolSelection;

  /// Callback to remove specific drawing from the list of drawings.
  final VoidCallback removeUnfinishedDrawing;

  @override
  DrawingCreatorState<RayLineDrawing> createState() =>
      _RayDrawingCreatorState();
}

class _RayDrawingCreatorState extends DrawingCreatorState<RayLineDrawing> {
  /// If drawing has been started.
  bool _isPenDown = false;

  Widget build(BuildContext context) {
    return Center(
      child: MouseRegion(
        cursor: SystemMouseCursors.move,
        onHover: onHover,
        opaque: false,
        child: Container(
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  void onHover(PointerHoverEvent event) {
    this.onPanUpdate(DragUpdateDetails(
          globalPosition: event.position,
          localPosition: event.localPosition,
          delta: event.delta,
        ));
  }

  @override
  void onPanUpdate(DragUpdateDetails details) {
// Only update if we already placed the beginning edge point
    if (_isPenDown && !isDrawingFinished) {
      setState(() {
// Update the current pointer position.
        position = details.localPosition;
// Create a temporary edge point from the current pointer location.
        EdgePoint tempEndPoint = EdgePoint(
          epoch: epochFromX!(position!.dx),
          quote: widget.quoteFromCanvasY(position!.dy),
        );

        // Remove any previously added preview line drawing,
        // so that we only have one dynamic line shown.
        drawingParts
            .removeWhere((part) => part.drawingPart == DrawingParts.line);

        // Add a new temporary RayLineDrawing from the first edge point to the current pointer.
        drawingParts.add(RayLineDrawing(
          drawingPart: DrawingParts.line,
          startEdgePoint: edgePoints.first,
          endEdgePoint: tempEndPoint,
          exceedEnd: true,
        ));

        // Optionally, pass updated edge points.
        // Here we combine the stored first point with the temporary point.
        widget.onAddDrawing(
          drawingId,
          drawingParts,
          isDrawingFinished: isDrawingFinished,
          edgePoints: <EdgePoint>[edgePoints.first, tempEndPoint],
        );
      });
    }
  }

  @override
  void onTap(TapUpDetails details) {
    super.onTap(details);
    final RayDrawingCreator _widget = widget as RayDrawingCreator;

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

        drawingParts.add(RayLineDrawing(
          drawingPart: DrawingParts.marker,
          startEdgePoint: edgePoints.first,
        ));
      } else if (!isDrawingFinished) {
        /// Draw final point and the whole line.
        _isPenDown = false;
        isDrawingFinished = true;
        final int currentTap = tapCount - 1;
        final int previousTap = tapCount - 2;

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
          drawingParts.addAll(<RayLineDrawing>[
            RayLineDrawing(
              drawingPart: DrawingParts.marker,
              endEdgePoint: edgePoints[currentTap],
            ),
            RayLineDrawing(
              drawingPart: DrawingParts.line,
              startEdgePoint: edgePoints[previousTap],
              endEdgePoint: edgePoints[currentTap],
              exceedEnd: true,
            )
          ]);
        }
      }
      widget.onAddDrawing(
        drawingId,
        drawingParts,
        isDrawingFinished: isDrawingFinished,
        edgePoints: <EdgePoint>[...edgePoints],
      );
    });
  }
}
