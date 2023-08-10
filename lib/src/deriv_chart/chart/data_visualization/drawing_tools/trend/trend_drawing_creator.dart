// ignore_for_file: use_setters_to_change_properties

import 'package:deriv_chart/deriv_chart.dart';
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
    required this.series,
    Key? key,
  }) : super(
          key: key,
          onAddDrawing: onAddDrawing,
          quoteFromCanvasY: quoteFromCanvasY,
        );

  /// Series of tick
  final DataSeries<Tick> series;

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

  /// Binary search to find closest index to the [epoch].
  int _findClosestIndex(int epoch, List<Tick>? entries) {
    int lo = 0;
    int hi = entries!.length - 1;
    int localEpoch = epoch;

    if (localEpoch > entries[hi].epoch) {
      localEpoch = entries[hi].epoch;
    } else if (localEpoch < entries[lo].epoch) {
      localEpoch = entries[lo].epoch;
    }

    while (lo <= hi) {
      final int mid = (hi + lo) ~/ 2;
      // int getEpochOf(T t, int index) => t.epoch;
      if (localEpoch < entries[mid].epoch) {
        hi = mid - 1;
      } else if (localEpoch > entries[mid].epoch) {
        lo = mid + 1;
      } else {
        return mid;
      }
    }

    return (entries[lo].epoch - localEpoch) < (localEpoch - entries[hi].epoch)
        ? lo
        : hi;
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
        // index of the start point in the series
        final int startPointIndex = _findClosestIndex(
            epochFromX!(position!.dx), _widget.series.entries);

        // starting point on graph
        final Tick? startingPoint = _widget.series.entries![startPointIndex];

        _startingPointEpoch = startingPoint!.epoch;

        /// Draw the initial point of the line.
        edgePoints.add(
          EdgePoint(
            epoch: startingPoint.epoch,
            quote: startingPoint.quote,
          ),
        );

        _isPenDown = true;

        drawingParts.add(
          TrendDrawing(
            epochFromX: epochFromX,
            drawingPart: DrawingParts.marker,
            startingEdgePoint: edgePoints.first,
            findClosestIndex: _findClosestIndex,
          ),
        );
      } else if (!isDrawingFinished) {
        edgePoints.add(
          EdgePoint(
            epoch: epochFromX!(position!.dx),
            quote: widget.quoteFromCanvasY(position!.dy),
          ),
        );

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
              findClosestIndex: _findClosestIndex,
              endingEdgePoint: endingEdgePoint,
            ),
            TrendDrawing(
              epochFromX: epochFromX,
              drawingPart: DrawingParts.line,
              startingEdgePoint: startingEdgePoint,
              findClosestIndex: _findClosestIndex,
              endingEdgePoint: endingEdgePoint,
            ),
            TrendDrawing(
              epochFromX: epochFromX,
              drawingPart: DrawingParts.marker,
              startingEdgePoint: startingEdgePoint,
              findClosestIndex: _findClosestIndex,
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
