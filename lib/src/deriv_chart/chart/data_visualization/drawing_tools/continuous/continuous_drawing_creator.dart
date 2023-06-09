import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/draggable_edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/line/line_drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data_model/drawing_parts.dart';

/// Creates a Continuous drawing piece by piece collected on every gesture
/// exists in a widget tree starting from selecting a continuous drawing tool
/// and until drawing should be finished.
class ContinuousDrawingCreator extends StatefulWidget {
  /// Initializes the continuous drawing creator.
  const ContinuousDrawingCreator({
    required this.onAddDrawing,
    required this.quoteFromCanvasY,
    required this.clearDrawingToolSelection,
    required this.removeDrawing,
    required this.shouldStopDrawing,
    Key? key,
  }) : super(key: key);

  /// Callback to pass a newly created line drawing to the parent.
  final void Function(Map<String, List<LineDrawing>> addedDrawing,
      {bool isDrawingFinished}) onAddDrawing;

  /// Conversion function for converting quote from chart's canvas' Y position.
  final double Function(double) quoteFromCanvasY;

  /// Callback to clean drawing tool selection.
  final VoidCallback clearDrawingToolSelection;

  /// Callback to remove specific drawing from the list of drawings.
  final void Function(String drawingId) removeDrawing;

  /// A flag to show when to stop drawing only for drawings which don't have
  /// fixed number of points like continuous drawing
  final bool shouldStopDrawing;

  @override
  _ContinuousDrawingCreatorState createState() =>
      _ContinuousDrawingCreatorState();
}

class _ContinuousDrawingCreatorState extends State<ContinuousDrawingCreator> {
  late GestureManagerState gestureManager;

  /// Parts of a particular line drawing, e.g. marker, line
  List<LineDrawing> _drawingParts = <LineDrawing>[];

  /// Tapped position.
  Offset? _position;

  /// Keeps track of how many times user tapped on the chart.
  int _tapCount = 0;

  final List<DraggableEdgePoint> _edgePoints = <DraggableEdgePoint>[];

  /// Unique drawing id.
  String _drawingId = '';

  /// If drawing has been finished.
  bool _isDrawingFinished = false;

  /// Get epoch from x.
  int Function(double x)? epochFromX;

  @override
  void initState() {
    super.initState();
    gestureManager = context.read<GestureManagerState>()
      ..registerCallback(_onTap);
  }

  @override
  void dispose() {
    gestureManager.removeCallback(_onTap);
    super.dispose();
  }

  void _onTap(TapUpDetails details) {
    if (widget.shouldStopDrawing) {
      return;
    } else {
      _isDrawingFinished = false;
    }
    setState(() {
      _position = details.localPosition;
      _tapCount++;

      if (_edgePoints.isEmpty) {
        /// Draw the initial point of the continuous.
        _edgePoints.add(DraggableEdgePoint(
          epoch: epochFromX!(_position!.dx),
          yCoord: widget.quoteFromCanvasY(_position!.dy),
        ));
        _drawingId = 'continuous_${_edgePoints.first.epoch}';

        _drawingParts.add(LineDrawing(
          drawingPart: DrawingParts.marker,
          startEpoch: _edgePoints.first.epoch!,
          startYCoord: _edgePoints.first.yCoord!,
        ));
      } else if (!_isDrawingFinished) {
        /// Draw other points and the whole continuous drawing.
        _isDrawingFinished = true;
        _edgePoints.add(DraggableEdgePoint(
          epoch: epochFromX!(_position!.dx),
          yCoord: widget.quoteFromCanvasY(_position!.dy),
        ));

        /// Checks if the initial point and the 2nd points are the same.
        if (Offset(_edgePoints[1].epoch!.toDouble(),
                _edgePoints[1].yCoord!.toDouble()) ==
            Offset(_edgePoints.first.epoch!.toDouble(),
                _edgePoints.first.yCoord!.toDouble())) {
          /// If the initial point and the 2nd point are the same,
          /// remove the drawing and clean the drawing tool selection.
          widget.removeDrawing(_drawingId);
          widget.clearDrawingToolSelection();
          return;
        } else {
          /// If the initial point and the final point are not the same,
          /// draw the final point and the whole drawing.
          if (_tapCount > 2) {
            _drawingId = 'continuous_${_edgePoints[_tapCount - 1].epoch}';
            _drawingParts = <LineDrawing>[];

            _drawingParts.add(LineDrawing(
              drawingPart: DrawingParts.marker,
              startEpoch: _edgePoints[_tapCount - 2].epoch!,
              startYCoord: _edgePoints[_tapCount - 2].yCoord!,
            ));
          }
          _drawingParts.addAll(<LineDrawing>[
            LineDrawing(
              drawingPart: DrawingParts.marker,
              endEpoch: _edgePoints[_tapCount - 1].epoch!,
              endYCoord: _edgePoints[_tapCount - 1].yCoord!,
            ),
            LineDrawing(
              drawingPart: DrawingParts.line,
              startEpoch: _edgePoints[_tapCount - 2].epoch!,
              startYCoord: _edgePoints[_tapCount - 2].yCoord!,
              endEpoch: _edgePoints[_tapCount - 1].epoch!,
              endYCoord: _edgePoints[_tapCount - 1].yCoord!,
            )
          ]);
        }
      }

      widget.onAddDrawing(
        <String, List<LineDrawing>>{_drawingId: _drawingParts},
        isDrawingFinished: _isDrawingFinished,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();
    epochFromX = xAxis.epochFromX;

    return Container();
  }
}
