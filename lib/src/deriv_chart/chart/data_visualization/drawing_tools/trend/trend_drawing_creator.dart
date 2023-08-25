// ignore_for_file: use_setters_to_change_properties

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing_creator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/trend/trend_drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/functions/min_max_calculator.dart';
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

  /// Stores the previously changed minimum epoch
  int prevMinimumEpoch = 0;

  /// Stores the previously changed maximum epoch
  int prevMaximumEpoch = 0;

  /// Instance of MinMaxCalculator class that holds the minimum
  /// and maximum quote in the trend range w.r.t epoch
  MinMaxCalculator? _calculator;

  static const int touchDistanceThreshold = 200;

  /// The area impacted upon touch on  all lines within the
  /// trend drawing tool. .i.e outer rectangle , inner rectangle
  /// and center line.
  final double _touchTolerance = 5;

  /// Binary search to find closest index to the [epoch].
  int _findClosestIndex(int epoch, List<Tick>? entries) {
    int lo = 0;
    int hi = entries!.length - 1;
    int localEpoch = epoch;

    if (localEpoch > entries[hi].epoch) {
      localEpoch = entries[hi].epoch;
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

  /// Setting the minmax calculator between the range of
  /// start and end epoch
  MinMaxCalculator? _setCalculator(
    int minimumEpoch,
    int maximumEpoch,
    List<Tick>? series,
  ) {
    if (prevMaximumEpoch != maximumEpoch || prevMinimumEpoch != minimumEpoch) {
      print('Calculating minmax calculator ${DateTime.now()}');
      prevMaximumEpoch = maximumEpoch;
      prevMinimumEpoch = minimumEpoch;
      int minimumEpochIndex = _findClosestIndex(minimumEpoch, series);
      int maximumEpochIndex = _findClosestIndex(maximumEpoch, series);

      if (minimumEpochIndex > maximumEpochIndex) {
        final int tempEpochIndex = minimumEpochIndex;
        minimumEpochIndex = maximumEpochIndex;
        maximumEpochIndex = tempEpochIndex;
      }

      final List<Tick>? epochRange =
          series!.sublist(minimumEpochIndex, maximumEpochIndex);

      double minValueOf(Tick t) => t.quote;
      double maxValueOf(Tick t) => t.quote;

      _calculator = MinMaxCalculator(minValueOf, maxValueOf)
        ..calculate(epochRange!);
    }
    return _calculator;
  }

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
            startEdgePoint: edgePoints.first,
            setCalculator: _setCalculator,
            isClickedOnRectangleBoundary: _isClickedOnRectangleBoundary,
            touchTolerance: _touchTolerance,
          )..onDrawingMoved(
              _widget.series.input,
              edgePoints.first,
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
              startEdgePoint: startingEdgePoint,
              endEdgePoint: endingEdgePoint,
              setCalculator: _setCalculator,
              isClickedOnRectangleBoundary: _isClickedOnRectangleBoundary,
              touchTolerance: _touchTolerance,
            )..onDrawingMoved(
                _widget.series.input,
                startingEdgePoint,
                endPoint: endingEdgePoint,
              ),
            TrendDrawing(
              epochFromX: epochFromX,
              drawingPart: DrawingParts.line,
              startEdgePoint: startingEdgePoint,
              endEdgePoint: endingEdgePoint,
              setCalculator: _setCalculator,
              isClickedOnRectangleBoundary: _isClickedOnRectangleBoundary,
              touchTolerance: _touchTolerance,
            )..onDrawingMoved(
                _widget.series.input,
                startingEdgePoint,
                endPoint: endingEdgePoint,
              ),
            TrendDrawing(
              epochFromX: epochFromX,
              drawingPart: DrawingParts.marker,
              startEdgePoint: startingEdgePoint,
              endEdgePoint: endingEdgePoint,
              setCalculator: _setCalculator,
              isClickedOnRectangleBoundary: _isClickedOnRectangleBoundary,
              touchTolerance: _touchTolerance,
            )..onDrawingMoved(
                _widget.series.input,
                startingEdgePoint,
                endPoint: endingEdgePoint,
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
