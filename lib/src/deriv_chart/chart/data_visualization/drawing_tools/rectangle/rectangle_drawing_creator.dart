import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './rectangle_drawing.dart';

/// Creates a Rectangle drawing piece by piece collected on every gesture
/// exists in a widget tree starting from selecting a Rectangle drawing tool and
/// until drawing is finished
class RectangleDrawingCreator extends StatefulWidget {
  /// Initializes the Rectangle drawing creator.
  const RectangleDrawingCreator({
    required this.onAddDrawing,
    required this.quoteFromCanvasY,
    Key? key,
  }) : super(key: key);

  /// Callback to pass a newly created Rectangle drawing to the parent.
  final void Function(Map<String, List<RectangleDrawing>> addedDrawing,
      {bool isDrawingFinished}) onAddDrawing;

  /// Conversion function for converting quote from chart's canvas' Y position.
  final double Function(double) quoteFromCanvasY;

  @override
  _RectangleDrawingCreatorState createState() =>
      _RectangleDrawingCreatorState();
}

class _RectangleDrawingCreatorState extends State<RectangleDrawingCreator> {
  late GestureManagerState gestureManager;

  /// Parts of a particular Rectangle drawing, e.g. marker, line
  final List<RectangleDrawing> _drawingParts = <RectangleDrawing>[];

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
        _startingYPoint = widget.quoteFromCanvasY(position!.dy);
        _isPenDown = true;
        _drawingId = 'rectangle_$_startingEpoch';

        _drawingParts.add(RectangleDrawing(
          drawingPart: 'marker',
          startEpoch: _startingEpoch!,
          startYCoord: _startingYPoint!,
        ));
      } else if (!_isDrawingFinished) {
        _isPenDown = false;
        _isDrawingFinished = true;
        final int endEpoch = epochFromX!(position!.dx);
        final double endYPoint = widget.quoteFromCanvasY(position!.dy);

        _drawingParts.addAll(<RectangleDrawing>[
          RectangleDrawing(
            drawingPart: 'marker',
            startEpoch: endEpoch,
            startYCoord: endYPoint,
          ),
          RectangleDrawing(
            drawingPart: 'line',
            startEpoch: _startingEpoch!,
            startYCoord: _startingYPoint!,
            endEpoch: endEpoch,
            endYCoord: endYPoint,
          )
        ]);
      }
      widget.onAddDrawing(
          <String, List<RectangleDrawing>>{_drawingId: _drawingParts},
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
