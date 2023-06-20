import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/trend/trend_drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data_model/drawing_parts.dart';

/// Creates a Line drawing piece by piece collected on every gesture
/// exists in a widget tree starting from selecting a line drawing tool and
/// until drawing is finished
class TrendDrawingCreator extends StatefulWidget {
  /// Initializes the line drawing creator.
  const TrendDrawingCreator({
    required this.onAddDrawing,
    required this.quoteFromCanvasY,
    required this.cleanDrawingToolSelection,
    required this.removeDrawing,
    required this.series,
    Key? key,
  }) : super(key: key);

  final DataSeries<Tick> series;

  /// Callback to pass a newly created line drawing to the parent.
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

  /// Parts of a particular line drawing, e.g. marker, line
  final List<TrendDrawing> _drawingParts = <TrendDrawing>[];

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
        /// Draw the initial point of the line.
        _startingEpoch = epochFromX!(position!.dx);
        _startingYPoint = widget.quoteFromCanvasY(position!.dy);
        _isPenDown = true;
        _drawingId = 'trend_$_startingEpoch';

        _drawingParts.add(TrendDrawing(
          epochFromX: epochFromX,
          series: widget.series,
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

        _drawingParts
          ..removeAt(0)
          ..addAll(<TrendDrawing>[
            TrendDrawing(
              epochFromX: epochFromX,
              series: widget.series,
              drawingPart: DrawingParts.rectangle,
              startEpoch: _startingEpoch!,
              startYCoord: _startingYPoint!,
              endEpoch: _endingEpoch!,
              endYCoord: _endingYPoint!,
            )
          ]);
      }
      // }
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
