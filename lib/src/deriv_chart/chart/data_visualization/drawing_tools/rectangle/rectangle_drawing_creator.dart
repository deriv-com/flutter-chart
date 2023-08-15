import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_creator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/rectangle/rectangle_drawing.dart';
import 'package:flutter/material.dart';
import '../data_model/drawing_parts.dart';

/// Creates a Rectangle drawing piece by piece collected on every gesture
/// exists in a widget tree starting from selecting a rectangle drawing tool and
/// until drawing is finished
class RectangleDrawingCreator extends DrawingCreator<RectangleDrawing> {
  /// Initializes the rectangle drawing creator.
  const RectangleDrawingCreator({
    required OnAddDrawing<RectangleDrawing> onAddDrawing,
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
  _RectangleDrawingCreatorState createState() =>
      _RectangleDrawingCreatorState();
}

class _RectangleDrawingCreatorState
    extends DrawingCreatorState<RectangleDrawing> {
  final int _touchTolerance = 10;

  /// Function to check if the clicked position (Offset) is on
  /// boundary of the rectangle
  bool _isClickedOnRectangleBoundary(Rect rect, Offset position) {
    /// Width of the rectangle line
    const double lineWidth = 3;

    final Rect topLineBounds = Rect.fromLTWH(
      rect.left - _touchTolerance,
      rect.top - _touchTolerance,
      rect.width + _touchTolerance * 2,
      lineWidth + _touchTolerance * 2,
    );

    final Rect leftLineBounds = Rect.fromLTWH(
      rect.left - _touchTolerance,
      rect.top - _touchTolerance,
      lineWidth + _touchTolerance * 2,
      rect.height + _touchTolerance * 2,
    );

    final Rect rightLineBounds = Rect.fromLTWH(
      rect.right - lineWidth - _touchTolerance * 2,
      rect.top - _touchTolerance,
      lineWidth + _touchTolerance * 2,
      rect.height + _touchTolerance * 2,
    );

    final Rect bottomLineBounds = Rect.fromLTWH(
      rect.left - _touchTolerance,
      rect.bottom - lineWidth - _touchTolerance * 2,
      rect.width + _touchTolerance * 2 + 2,
      lineWidth + _touchTolerance * 2 + 2,
    );

    return topLineBounds.inflate(2).contains(position) ||
        leftLineBounds.inflate(2).contains(position) ||
        rightLineBounds.inflate(2).contains(position) ||
        bottomLineBounds.inflate(2).contains(position);
  }

  /// If drawing has been started.
  bool _isPenDown = false;

  @override
  void onTap(TapUpDetails details) {
    super.onTap(details);

    final RectangleDrawingCreator _widget = widget as RectangleDrawingCreator;

    if (isDrawingFinished) {
      return;
    }
    setState(() {
      position = details.localPosition;
      if (!_isPenDown) {
        /// Draw the initial point.
        edgePoints.add(EdgePoint(
          epoch: epochFromX!(position!.dx),
          quote: widget.quoteFromCanvasY(position!.dy),
        ));

        _isPenDown = true;

        drawingParts.add(
          RectangleDrawing(
            drawingPart: DrawingParts.marker,
            isClickedOnRectangleBoundary: _isClickedOnRectangleBoundary,
            startEdgePoint: edgePoints.first,
          ),
        );
      } else if (!isDrawingFinished) {
        /// Draw second point and the rectangle.
        _isPenDown = false;
        isDrawingFinished = true;

        edgePoints.add(EdgePoint(
          epoch: epochFromX!(position!.dx),
          quote: widget.quoteFromCanvasY(position!.dy),
        ));

        final EdgePoint startEdgePoint = edgePoints.first;
        final EdgePoint endEdgePoint = edgePoints[1];

        if (endEdgePoint == startEdgePoint) {
          _widget.removeDrawing(drawingId);
          _widget.clearDrawingToolSelection();
          return;
        } else {
          drawingParts.addAll(<RectangleDrawing>[
            RectangleDrawing(
              drawingPart: DrawingParts.marker,
              isClickedOnRectangleBoundary: _isClickedOnRectangleBoundary,
              endEdgePoint: endEdgePoint,
            ),
            RectangleDrawing(
              drawingPart: DrawingParts.rectangle,
              isClickedOnRectangleBoundary: _isClickedOnRectangleBoundary,
              startEdgePoint: startEdgePoint,
              endEdgePoint: endEdgePoint,
            )
          ]);
        }
      }

      widget.onAddDrawing(
        drawingId,
        drawingParts,
        isDrawingFinished: isDrawingFinished,
      );
    });
  }
}
