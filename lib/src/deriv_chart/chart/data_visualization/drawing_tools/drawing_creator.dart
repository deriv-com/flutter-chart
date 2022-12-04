import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/line_drawing.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../add_ons/drawing_tools_ui/drawing_tool_config.dart';

/// used to create a drawing piece by piece collected on every gesture
/// exists in a widget tree starting from selecting a selectedDrawingTool and
/// until drawing is finished
class DrawingCreator extends StatefulWidget {
  /// Initializes drawing creator area.
  const DrawingCreator({
    required this.onAddDrawing,
    required this.selectedDrawingTool,
    Key? key,
  }) : super(key: key);

  /// selected drawing tool;
  final DrawingToolConfig selectedDrawingTool;

  /// callback to pass a newly created drawing to the parent;
  final void Function(Map<String, List<Drawing>> addedDrawing,
      {bool isDrawingFinished}) onAddDrawing;

  @override
  _DrawingCreatorState createState() => _DrawingCreatorState();
}

class _DrawingCreatorState extends State<DrawingCreator> {
  late GestureManagerState gestureManager;

  /// parts of a particular drawing, e.g. marker, line
  final List<Drawing> _drawingParts = <Drawing>[];

  /// tapped position
  Offset? position;

  /// saved starting epoch;
  int? _startingEpoch;

  /// saved starting Y coordinates;
  double? _startingYPoint;

  /// if drawing has been started;
  bool _isPenDown = false;

  /// unique drawing id;
  String _drawingId = '';

  /// if drawing has been finished;
  bool _isDrawingFinished = false;

  /// get epoch from x
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
      final String drawingToolType =
          widget.selectedDrawingTool.toJson()['name'];
      switch (drawingToolType) {
        case 'line':
          if (!_isPenDown) {
            _startingEpoch = epochFromX!(position!.dx);
            _startingYPoint = position!.dy;
            _isPenDown = true;
            _drawingId = '${drawingToolType}_$_startingEpoch';

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
          break;
        // TODO(maryia-binary): add cases for other drawing tools here
        default:
          return;
      }
      widget.onAddDrawing(<String, List<Drawing>>{_drawingId: _drawingParts},
          isDrawingFinished: _isDrawingFinished);
    });
  }

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();
    epochFromX = xAxis.epochFromX;

    return Stack(children: <Widget>[Container()]);
  }
}
