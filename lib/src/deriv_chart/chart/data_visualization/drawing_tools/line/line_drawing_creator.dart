import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data_model/drawing_parts.dart';
import './line_drawing.dart';

/// Creates a Line drawing piece by piece collected on every gesture
/// exists in a widget tree starting from selecting a line drawing tool and
/// until drawing is finished
class LineDrawingCreator extends StatefulWidget {
  /// Initializes the line drawing creator.
  const LineDrawingCreator({
    required this.onAddDrawing,
    required this.quoteFromCanvasY,
    required this.clearDrawingToolSelection,
    required this.removeDrawing,
    Key? key,
  }) : super(key: key);

  /// Callback to pass a newly created line drawing to the parent.
  final void Function(Map<String, List<LineDrawing>> addedDrawing,
      {bool isDrawingFinished, int totalPoints}) onAddDrawing;

  /// Conversion function for converting quote from chart's canvas' Y position.
  final double Function(double) quoteFromCanvasY;

  /// Callback to clean drawing tool selection.
  final VoidCallback clearDrawingToolSelection;

  /// Callback to remove specific drawing from the list of drawings.
  final void Function(String drawingId) removeDrawing;

  @override
  _LineDrawingCreatorState createState() => _LineDrawingCreatorState();
}

class _LineDrawingCreatorState extends State<LineDrawingCreator> {
  late GestureManagerState gestureManager;

  /// Parts of a particular line drawing, e.g. marker, line
  final List<LineDrawing> _drawingParts = <LineDrawing>[];

  /// Tapped position.
  Offset? position;

  /// Saved starting epoch.
  int? _startingEpoch;

  /// Saved starting Y coordinates.
  double? _startingYPoint;

  /// Saved ending epoch.
  int? _endingEpoch;

  /// Saved ending Y coordinates.
  double? _endingYPoint;

  /// If drawing has been started.
  bool _isPenDown = false;

  /// Unique drawing id.
  String _drawingId = '';

  /// If drawing has been finished.
  bool _isDrawingFinished = false;

  /// Get epoch from x.
  int Function(double x)? epochFromX;

  // total point required to create the drawing
  final int totalPoints = 2;

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
    if (_isDrawingFinished) {
      return;
    }
    setState(() {
      position = details.localPosition;
      if (!_isPenDown) {
        /// Draw the initial point of the line.
        _startingEpoch = epochFromX!(position!.dx);
        _startingYPoint = widget.quoteFromCanvasY(position!.dy);
        _isPenDown = true;
        _drawingId = 'line_$_startingEpoch';

        _drawingParts.add(LineDrawing(
          drawingPart: DrawingParts.marker,
          startEpoch: _startingEpoch!,
          startYCoord: _startingYPoint!,
        ));
      } else if (!_isDrawingFinished) {
        /// Draw final point and the whole line.
        _isPenDown = false;
        _isDrawingFinished = true;
        _endingEpoch = epochFromX!(position!.dx);
        _endingYPoint = widget.quoteFromCanvasY(position!.dy);

        /// Checks if the initial point and the final point are the same.
        if (Offset(_startingEpoch!.toDouble(), _startingYPoint!.toDouble()) ==
            Offset(_endingEpoch!.toDouble(), _endingYPoint!.toDouble())) {
          /// If the initial point and the final point are the same,
          /// remove the drawing and cleazn the drawing tool selection.
          widget.removeDrawing(_drawingId);
          widget.clearDrawingToolSelection();
          return;
        } else {
          /// If the initial point and the final point are not the same,
          /// draw the final point and the whole line.
          _drawingParts.addAll(<LineDrawing>[
            LineDrawing(
              drawingPart: DrawingParts.marker,
              endEpoch: _endingEpoch!,
              endYCoord: _endingYPoint!,
            ),
            LineDrawing(
              drawingPart: DrawingParts.line,
              startEpoch: _startingEpoch!,
              startYCoord: _startingYPoint!,
              endEpoch: _endingEpoch!,
              endYCoord: _endingYPoint!,
            )
          ]);
        }
      }
      widget.onAddDrawing(
          <String, List<LineDrawing>>{_drawingId: _drawingParts},
          isDrawingFinished: _isDrawingFinished, totalPoints: totalPoints);
    });
  }

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();
    epochFromX = xAxis.epochFromX;

    return Container();
  }
}
