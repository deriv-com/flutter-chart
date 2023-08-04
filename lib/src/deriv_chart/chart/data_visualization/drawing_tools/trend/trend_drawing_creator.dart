// ignore_for_file: use_setters_to_change_properties

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_creator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/trend/trend_drawing.dart';
import 'package:flutter/material.dart';
import '../data_model/drawing_parts.dart';

/// Creates a Trend drawing right after selecting the trend drawing tool
/// and until drawing is finished
class TrendDrawingCreator extends DrawingCreator<TrendDrawing> {
  /// Initializes the trend drawing creator.
  const TrendDrawingCreator({
    required OnAddDrawing<TrendDrawing> onAddDrawing,
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
  DrawingCreatorState<TrendDrawing> createState() =>
      _TrendDrawingCreatorState();
}

class _TrendDrawingCreatorState extends DrawingCreatorState<TrendDrawing> {
  /// If drawing has been started.
  bool _isPenDown = false;

  /// Stores coordinate of first point on the graph
  int? _startingPointEpoch;

  static const int touchDistanceThreshold = 200;

  void getStartingPointEpoch(int? epoch) {
    // the epoch of the starting point that is mapped on the graph
    _startingPointEpoch = epoch;
  }

  @override
  void onTap(TapUpDetails details) {
    super.onTap(details);
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
          quote: widget.quoteFromCanvasY(position!.dy),
        ));

        _isPenDown = true;

        drawingParts.add(
          TrendDrawing(
            epochFromX: epochFromX,
            drawingPart: DrawingParts.marker,
            startingEdgePoint: edgePoints.first,
            getFirstActualClick: getStartingPointEpoch,
          ),
        );
      } else if (!isDrawingFinished) {
        edgePoints.add(EdgePoint(
          epoch: epochFromX!(position!.dx),
          quote: widget.quoteFromCanvasY(position!.dy),
        ));

        /// Draw final drawing
        _isPenDown = false;
        isDrawingFinished = true;
        final EdgePoint startingEdgePoint = edgePoints.first;
        final EdgePoint endingEdgePoint = edgePoints[1];

        // When the second point is on the same y
        // coordinate as the first point
        if ((_startingPointEpoch! - endingEdgePoint.epoch).abs() <=
            touchDistanceThreshold) {
          /// remove the drawing and clean the drawing tool selection.
          _widget.removeDrawing(drawingId);
          _widget.clearDrawingToolSelection();
          return;
        }

        drawingParts
          ..removeAt(0)
          ..addAll(<TrendDrawing>[
            TrendDrawing(
              epochFromX: epochFromX,
              drawingPart: DrawingParts.rectangle,
              startingEdgePoint: startingEdgePoint,
              endingEdgePoint: endingEdgePoint,
            ),
            TrendDrawing(
              epochFromX: epochFromX,
              drawingPart: DrawingParts.line,
              startingEdgePoint: startingEdgePoint,
              endingEdgePoint: endingEdgePoint,
            ),
            TrendDrawing(
              epochFromX: epochFromX,
              drawingPart: DrawingParts.marker,
              startingEdgePoint: startingEdgePoint,
              endingEdgePoint: endingEdgePoint,
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
