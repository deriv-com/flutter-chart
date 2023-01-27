import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './vertical_drawing.dart';

/// Creates a Vertical line drawing
class VerticalDrawingCreator extends StatefulWidget {
  /// Initializes the vertical drawing creator.
  const VerticalDrawingCreator({
    required this.onAddDrawing,
    Key? key,
  }) : super(key: key);

  /// Callback to pass a newly created vertical drawing to the parent.
  final void Function(Map<String, List<VerticalDrawing>> addedDrawing,
      {bool isDrawingFinished}) onAddDrawing;

  @override
  _VerticalDrawingCreatorState createState() => _VerticalDrawingCreatorState();
}

class _VerticalDrawingCreatorState extends State<VerticalDrawingCreator> {
  late GestureManagerState gestureManager;

  /// Parts of a particular vertical drawing, e.g. marker, line
  final List<VerticalDrawing> _drawingParts = <VerticalDrawing>[];

  /// Tapped position.
  Offset? position;

  /// Saved starting epoch.
  int? _startingEpoch;

  /// Saved starting Y coordinates.
  double? _startingYPoint;

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
      _startingEpoch = epochFromX!(position!.dx);
      _startingYPoint = position!.dy;
      _drawingId = 'vertical_$_startingEpoch';
      _isDrawingFinished = true;

      _drawingParts.add(VerticalDrawing(
        drawingPart: 'vertical',
        epoch: _startingEpoch!,
        yCoord: _startingYPoint!,
      ));

      widget.onAddDrawing(
          <String, List<VerticalDrawing>>{_drawingId: _drawingParts},
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
