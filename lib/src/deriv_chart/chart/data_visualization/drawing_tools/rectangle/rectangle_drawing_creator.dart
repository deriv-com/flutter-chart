import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/rectangle/rectangle_drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data_model/drawing_parts.dart';

/// Creates a Rectangle drawing piece by piece collected on every gesture
/// exists in a widget tree starting from selecting a rectangle drawing tool and
/// until drawing is finished
class RectangleDrawingCreator extends StatefulWidget {
  /// Initializes the rectangle drawing creator.
  const RectangleDrawingCreator({
    required this.onAddDrawing,
    required this.quoteFromCanvasY,
    required this.cleanDrawingToolSelection,
    required this.removeDrawing,
    Key? key,
  }) : super(key: key);

  /// Callback to pass a newly created rectangle drawing to the parent.
  final void Function(Map<String, List<RectangleDrawing>> addedDrawing,
      {bool isDrawingFinished}) onAddDrawing;

  /// Conversion function for converting quote from chart's canvas' Y position.
  final double Function(double) quoteFromCanvasY;

  /// Callback to clean drawing tool selection.
  final VoidCallback cleanDrawingToolSelection;

  /// Callback to remove specific drawing from the list of drawings.
  final void Function(String drawingId) removeDrawing;

  @override
  _RectangleDrawingCreatorState createState() =>
      _RectangleDrawingCreatorState();
}

class _RectangleDrawingCreatorState extends State<RectangleDrawingCreator> {
  late GestureManagerState gestureManager;

  /// List to maintain instance of Rectangle drawing with
  /// multiple input to be passed to onAddDrawing Callback
  final List<RectangleDrawing> _drawingParts = <RectangleDrawing>[];

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
        /// Draw the initial point.
        _startingEpoch = epochFromX!(position!.dx);
        _startingYPoint = widget.quoteFromCanvasY(position!.dy);
        _isPenDown = true;
        _drawingId = 'rectangle$_startingEpoch';

        _drawingParts.add(RectangleDrawing(
            drawingPart: DrawingParts.marker,
            startEpoch: _startingEpoch!,
            startQuote: _startingYPoint!));
      } else if (!_isDrawingFinished) {
        /// Draw second point and the rectangle.
        _isPenDown = false;
        _isDrawingFinished = true;
        _endingEpoch = epochFromX!(position!.dx);

        _endingYPoint = widget.quoteFromCanvasY(position!.dy);

        if (Offset(_startingEpoch!.toDouble(), _startingYPoint!.toDouble()) ==
            Offset(_endingEpoch!.toDouble(), _endingYPoint!.toDouble())) {
          widget.removeDrawing(_drawingId);
          widget.cleanDrawingToolSelection();
          return;
        } else {
          _drawingParts.addAll(<RectangleDrawing>[
            RectangleDrawing(
              drawingPart: DrawingParts.marker,
              endEpoch: _endingEpoch!,
              endQuote: _endingYPoint!,
            ),
            RectangleDrawing(
              drawingPart: DrawingParts.rectangle,
              startEpoch: _startingEpoch!,
              startQuote: _startingYPoint!,
              endEpoch: _endingEpoch!,
              endQuote: _endingYPoint!,
            )
          ]);
        }
      }

      widget.onAddDrawing(<String, List<RectangleDrawing>>{
        _drawingId: _drawingParts,
      }, isDrawingFinished: _isDrawingFinished);
    });
  }

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();
    epochFromX = xAxis.epochFromX;

    return Container();
  }
}
