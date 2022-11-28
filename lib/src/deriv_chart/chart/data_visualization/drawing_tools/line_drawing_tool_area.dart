import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Layer with markers.
class LineDrawingToolArea extends StatefulWidget {
  /// Initializes marker area.
  const LineDrawingToolArea({
    Key? key,
  }) : super(key: key);

  @override
  _LineDrawingToolAreaState createState() => _LineDrawingToolAreaState();
}

class _LineDrawingToolAreaState extends State<LineDrawingToolArea> {
  late GestureManagerState gestureManager;

  /// if drawing has been started.
  final List<LineDrawingTool> _lineDrawings = <LineDrawingTool>[];

  /// tapped position
  Offset? position;

  /// saved starting epoch;
  int? _startingEpoch;

  /// saved starting Y coordinates;
  double? _startingYPoint;

  /// if drawing has been started;
  bool _isPenDown = false;

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
    _lineDrawings.clear();
  }

  void _onTap(TapUpDetails details) {
    setState(() {
      position = details.localPosition;
      if (_isDrawingFinished) {
        return;
      }
      if (!_isPenDown) {
        _startingEpoch = epochFromX!(position!.dx);
        _startingYPoint = position!.dy;
        _isPenDown = true;
        _lineDrawings.add(LineDrawingTool(
            drawingType: 'marker',
            startEpoch: _startingEpoch!,
            startYCoord: _startingYPoint!));
      } else if (!_isDrawingFinished) {
        _isPenDown = false;
        _isDrawingFinished = true;
        final int endEpoch = epochFromX!(position!.dx);
        final double endYPoint = position!.dy;

        _lineDrawings.addAll(<LineDrawingTool>[
          ..._lineDrawings,
          LineDrawingTool(
              drawingType: 'marker',
              startEpoch: endEpoch,
              startYCoord: endYPoint),
          LineDrawingTool(
            drawingType: 'line',
            startEpoch: _startingEpoch!,
            startYCoord: _startingYPoint!,
            endEpoch: endEpoch,
            endYCoord: endYPoint,
          )
        ]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();
    epochFromX = xAxis.epochFromX;

    return Stack(children: <Widget>[
      _startingEpoch != null && _startingYPoint != null
          ? CustomPaint(
              child: Container(
                padding: const EdgeInsets.only(right: 60),
              ),
              painter: _LineDrawingToolPainter(
                lineDrawings: _lineDrawings,
                theme: context.watch<ChartTheme>(),
                epochToX: xAxis.xFromEpoch,
              ))
          : Container()
    ]);
  }
}

class _LineDrawingToolPainter extends CustomPainter {
  _LineDrawingToolPainter({
    required this.lineDrawings,
    required this.theme,
    required this.epochToX,
  });

  final List<LineDrawingTool> lineDrawings;
  final ChartTheme theme;
  double Function(int x) epochToX;

  @override
  void paint(Canvas canvas, Size size) {
    lineDrawings.asMap().forEach((int index, LineDrawingTool element) {
      element.onPaint(canvas, size, theme, epochToX);
    });
  }

  @override
  bool shouldRepaint(_LineDrawingToolPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_LineDrawingToolPainter oldDelegate) => false;
}

/// line drawing tool
class LineDrawingTool {
  /// initializes
  LineDrawingTool({
    required this.drawingType,
    this.startEpoch = 0,
    this.startYCoord = 0,
    this.endEpoch = 0,
    this.endYCoord = 0,
  });

  /// if second tap has been made
  final String drawingType;

  /// starting epoch
  final int? startEpoch;

  /// starting Y coordinates
  final double? startYCoord;

  /// ending epoch
  final int? endEpoch;

  /// ending Y coordinates
  final double? endYCoord;

  /// marker radius
  final double markerRadius = 4;

  /// calculate y intersection
  double? yIntersection(Map<String, double?> vector, double x) {
    final double x1 = vector['x0']!, x2 = vector['x1']!, x3 = x, x4 = x;
    final double y1 = vector['y0']!, y2 = vector['y1']!, y3 = 0, y4 = 10000;
    final double denom = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1);
    final double numera = (x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3);

    double mua = numera / denom;
    if (denom == 0) {
      if (numera == 0) {
        mua = 1;
      } else {
        return null;
      }
    }

    final double y = y1 + mua * (y2 - y1);
    return y;
  }

  /// paint
  void onPaint(Canvas canvas, Size size, ChartTheme theme,
      double Function(int x) epochToX) {
    if (drawingType == 'marker') {
      if (startEpoch != null && startYCoord != null) {
        final double startXCoord = epochToX(startEpoch!);
        canvas.drawCircle(Offset(startXCoord, startYCoord!), markerRadius,
            Paint()..color = theme.base02Color);
      }
    } else if (drawingType == 'line') {
      if (startEpoch != null &&
          endEpoch != null &&
          startYCoord != null &&
          endYCoord != null) {
        final double startXCoord = epochToX(startEpoch!);
        final double endXCoord = epochToX(endEpoch!);

        Map<String, double?> vector = <String, double?>{
          'x0': startXCoord,
          'y0': startYCoord,
          'x1': endXCoord,
          'y1': endYCoord
        };
        if (vector['x0']! > vector['x1']!) {
          vector = <String, double?>{
            'x0': endXCoord,
            'y0': endYCoord!,
            'x1': startXCoord,
            'y1': startYCoord!
          };
        }
        final double earlier = vector['x0']! - 1000;
        final double later = vector['x1']! + 1000;

        final double startY = yIntersection(vector, earlier) ?? 0,
            endingY = yIntersection(vector, later) ?? 0,
            startX = earlier,
            endingX = later;

        canvas.drawLine(
            Offset(startX, startY),
            Offset(endingX, endingY),
            Paint()
              ..color = theme.base02Color
              ..strokeWidth = 1);
      }
    }
  }
}
