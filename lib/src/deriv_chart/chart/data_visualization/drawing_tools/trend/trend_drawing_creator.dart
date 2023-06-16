import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'trend_drawing.dart';

/// Creates a Trend line drawing
class TrendDrawingCreator extends StatefulWidget {
  /// Initializes the trend drawing creator.
  const TrendDrawingCreator({
    required this.onAddDrawing,
    required this.quoteFromCanvasY,
    Key? key,
  }) : super(key: key);

  /// Callback to pass a newly created trend drawing to the parent.
  final void Function(Map<String, List<TrendDrawing>> addedDrawing,
      {bool isDrawingFinished}) onAddDrawing;

  /// Conversion function for converting quote from chart's canvas' Y position.
  final double Function(double) quoteFromCanvasY;

  @override
  _TrendDrawingCreatorState createState() => _TrendDrawingCreatorState();
}

class _TrendDrawingCreatorState extends State<TrendDrawingCreator> {
  late GestureManagerState gestureManager;

  /// Parts of a particular trend drawing, e.g. marker, line
  final List<TrendDrawing> _drawingParts = <TrendDrawing>[];

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
      _startingYPoint = widget.quoteFromCanvasY(position!.dy);
      _drawingId = 'trend_$_startingEpoch';
      _isDrawingFinished = true;

      _drawingParts.add(TrendDrawing(
        drawingPart: DrawingParts.line,
        epoch: _startingEpoch!,
        yCoord: _startingYPoint!,
      ));

      widget.onAddDrawing(
        <String, List<TrendDrawing>>{_drawingId: _drawingParts},
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
