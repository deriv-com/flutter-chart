import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_parts.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './horizontal_drawing.dart';

/// Creates a Horizontal line drawing
class HorizontalDrawingCreator extends StatefulWidget {
  /// Initializes the horizontal drawing creator.
  const HorizontalDrawingCreator({
    required this.onAddDrawing,
    required this.quoteFromCanvasY,
    Key? key,
  }) : super(key: key);

  /// Callback to pass a newly created horizontal drawing to the parent.
  final void Function(Map<String, List<HorizontalDrawing>> addedDrawing,
      {bool isDrawingFinished}) onAddDrawing;

  /// Conversion function for converting quote from chart's canvas' Y position.
  final double Function(double) quoteFromCanvasY;

  @override
  _HorizontalDrawingCreatorState createState() =>
      _HorizontalDrawingCreatorState();
}

class _HorizontalDrawingCreatorState extends State<HorizontalDrawingCreator> {
  late GestureManagerState gestureManager;

  /// Parts of a particular horizontal drawing, e.g. marker, line
  final List<HorizontalDrawing> _drawingParts = <HorizontalDrawing>[];

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
      _drawingId = 'horizontal_$_startingEpoch';
      _isDrawingFinished = true;

      _drawingParts.add(HorizontalDrawing(
        drawingPart: DrawingParts.line,
        epoch: _startingEpoch!,
        yCoord: _startingYPoint!,
      ));

      widget.onAddDrawing(
        <String, List<HorizontalDrawing>>{_drawingId: _drawingParts},
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
