import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './line_drawing.dart';

/// Creates a line drawing piece by piece collected on every gesture
/// exists in a widget tree starting from selecting a selectedDrawingTool and
/// until drawing is finished
class LineDrawingCreator extends StatefulWidget {
  /// Initializes drawing creator area.
  const LineDrawingCreator({
    required this.onAddDrawing,
    Key? key,
  }) : super(key: key);

  /// Callback to pass a newly created drawing to the parent.
  final void Function(Map<String, List<LineDrawing>> addedDrawing,
      {bool isDrawingFinished}) onAddDrawing;

  @override
  _LineDrawingCreatorState createState() => _LineDrawingCreatorState();
}

class _LineDrawingCreatorState extends State<LineDrawingCreator> {
  late GestureManagerState gestureManager;

  /// Parts of a particular drawing, e.g. marker, line
  final List<LineDrawing> _drawingParts = <LineDrawing>[];

  /// Tapped position.
  Offset? position;

  /// Saved starting epoch.
  int? _startingEpoch;

  /// Saved starting Y coordinates.
  double? _startingYPoint;

  /// If drawing has been started.
  bool _isPenDown = false;

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
    if (_isDrawingFinished) {
      return;
    }
    setState(() {
      position = details.localPosition;
      if (!_isPenDown) {
        _startingEpoch = epochFromX!(position!.dx);
        _startingYPoint = position!.dy;
        _isPenDown = true;
        _drawingId = 'line_$_startingEpoch';

        _drawingParts.add(LineDrawing(
          drawingPart: 'marker',
          startEpoch: _startingEpoch!,
          startYCoord: _startingYPoint!,
        ));
      } else if (!_isDrawingFinished) {
        _isPenDown = false;
        _isDrawingFinished = true;
        final int endEpoch = epochFromX!(position!.dx);
        final double endYPoint = position!.dy;

        _drawingParts.addAll(<LineDrawing>[
          LineDrawing(
            drawingPart: 'marker',
            startEpoch: endEpoch,
            startYCoord: endYPoint,
          ),
          LineDrawing(
            drawingPart: 'line',
            startEpoch: _startingEpoch!,
            startYCoord: _startingYPoint!,
            endEpoch: endEpoch,
            endYCoord: endYPoint,
          )
        ]);
      }
      widget.onAddDrawing(
          <String, List<LineDrawing>>{_drawingId: _drawingParts},
          isDrawingFinished: _isDrawingFinished);
    });
  }

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();
    epochFromX = xAxis.epochFromX;

    return Container();
  }
}
