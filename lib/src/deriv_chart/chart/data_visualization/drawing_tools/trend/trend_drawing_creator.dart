import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/trend/trend_drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data_model/drawing_parts.dart';

/// Creates a Trend drawing right after selecting the trend drawing tool
/// and until drawing is finished
class TrendDrawingCreator extends StatefulWidget {
  /// Initializes the trend drawing creator.
  const TrendDrawingCreator({
    required this.onAddDrawing,
    required this.quoteFromCanvasY,
    required this.cleanDrawingToolSelection,
    required this.removeDrawing,
    Key? key,
  }) : super(key: key);

  /// Callback to pass a newly created trend drawing to the parent.
  final void Function(Map<String, List<TrendDrawing>> addedDrawing,
      {bool isDrawingFinished}) onAddDrawing;

  /// Conversion function for converting quote from chart's canvas' Y position.
  final double Function(double) quoteFromCanvasY;

  /// Callback to clean drawing tool selection.
  final VoidCallback cleanDrawingToolSelection;

  /// Callback to remove specific drawing from the list of drawings.
  final void Function(String drawingId) removeDrawing;

  @override
  _TrendDrawingCreatorState createState() => _TrendDrawingCreatorState();
}

class _TrendDrawingCreatorState extends State<TrendDrawingCreator> {
  late GestureManagerState gestureManager;

  /// List to maintain instance of Trend drawing with
  /// multiple input to be passed to onAddDrawing Callback
  final List<TrendDrawing> _drawingParts = <TrendDrawing>[];

  /// Tapped position.
  Offset? position;

  /// Saved starting epoch.
  int? _startingEpoch;

  /// Saved starting Y coordinates.
  double? _startingYQuote;

  /// Saved ending epoch.
  int? _endingEpoch;

  /// Saved ending Y coordinates.
  double? _endingYQuote;

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
        /// Draw the initial point of the line.
        _startingEpoch = epochFromX!(position!.dx);
        _startingYQuote = widget.quoteFromCanvasY(position!.dy);
        _isPenDown = true;
        _drawingId = 'trend_$_startingEpoch';

        _drawingParts.add(TrendDrawing(
          epochFromX: epochFromX,
          drawingPart: DrawingParts.marker,
          startingEpoch: _startingEpoch!,
          startingQuote: _startingYQuote!,
        ));
      } else if (!_isDrawingFinished) {
        /// Draw final drawing
        _isPenDown = false;
        _isDrawingFinished = true;
        _endingEpoch = epochFromX!(position!.dx);
        _endingYQuote = widget.quoteFromCanvasY(position!.dy);

        _drawingParts
          ..removeAt(0)
          ..add(
            TrendDrawing(
              epochFromX: epochFromX,
              drawingPart: DrawingParts.rectangle,
              startingEpoch: _startingEpoch!,
              startingQuote: _startingYQuote!,
              endingEpoch: _endingEpoch!,
              endingQuote: _endingYQuote!,
            ),
          )
          ..add(
            TrendDrawing(
              epochFromX: epochFromX,
              drawingPart: DrawingParts.line,
              startingEpoch: _startingEpoch!,
              startingQuote: _startingYQuote!,
              endingEpoch: _endingEpoch!,
              endingQuote: _endingYQuote!,
            ),
          )
          ..add(TrendDrawing(
            epochFromX: epochFromX,
            drawingPart: DrawingParts.marker,
            startingEpoch: _startingEpoch!,
            startingQuote: _startingYQuote!,
            endingEpoch: _endingEpoch!,
            endingQuote: _endingYQuote!,
          ));
      }

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
