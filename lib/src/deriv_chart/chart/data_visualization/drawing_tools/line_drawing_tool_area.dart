import 'dart:math';

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

  /// saved starting point coordinates;
  Offset? _startingPoint;

  /// if drawing has been started;
  bool _isPenDown = false;

  /// if drawing has been finished;
  bool _isDrawingFinished = false;

  XAxisModel get xAxis => context.read<XAxisModel>();

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
        _startingPoint = Offset(position!.dx, position!.dy);
        _isPenDown = true;
        _lineDrawings.add(
            LineDrawingTool(drawingType: 'marker', start: _startingPoint!));
      } else if (!_isDrawingFinished) {
        _isPenDown = false;
        _isDrawingFinished = true;
        final Offset center = Offset(position!.dx, position!.dy);
        _lineDrawings.addAll(<LineDrawingTool>[
          ..._lineDrawings,
          LineDrawingTool(drawingType: 'marker', start: center),
          LineDrawingTool(
            drawingType: 'line',
            start: _startingPoint!,
            end: center,
          )
        ]);
      }
    });
  }

  @override
  Widget build(BuildContext context) => Stack(children: <Widget>[
        _startingPoint != null
            ? CustomPaint(
                child: Container(
                  padding: const EdgeInsets.only(right: 60),
                ),
                painter: _LineDrawingToolPainter(
                  lineDrawings: _lineDrawings,
                  theme: context.watch<ChartTheme>(),
                ))
            : Container()
      ]);
}

class _LineDrawingToolPainter extends CustomPainter {
  _LineDrawingToolPainter({
    required this.lineDrawings,
    required this.theme,
  });

  final List<LineDrawingTool> lineDrawings;
  final ChartTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    lineDrawings.asMap().forEach((int index, LineDrawingTool element) {
      element.onPaint(canvas, size, theme);
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
    this.start = const Offset(0, 0),
    this.end = const Offset(0, 0),
  });

  /// if second tap has been made
  final String drawingType;

  /// starting coordinates
  final Offset start;

  /// ending coordinates
  final Offset end;

  /// marker radius
  final double markerRadius = 4;

  /// paint
  void onPaint(Canvas canvas, Size size, ChartTheme theme) {
    if (drawingType == 'marker') {
      canvas.drawCircle(
          start, markerRadius, Paint()..color = theme.base02Color);
    } else if (drawingType == 'line') {
      double startX = 0, startY = 0, endX = 0, endY = 0;
      final double xDiff = (end.dx - start.dx).abs();
      final double yDiff = (end.dy - start.dy).abs();
      final double diagonal = sqrt(pow(size.height, 2) + pow(size.width, 2));
      final double count = xDiff == 0 || yDiff == 0
          ? diagonal / max(xDiff, yDiff)
          : diagonal / min(xDiff, yDiff);
      for (int i = 1; i < count; i++) {
        final double xIncrement = start.dx > end.dx ? xDiff * i : -(xDiff * i);
        final double yIncrement = start.dy > end.dy ? yDiff * i : -(yDiff * i);
        startX = start.dx + xIncrement;
        startY = start.dy + yIncrement;
        endX = end.dx + -xIncrement;
        endY = end.dy + -yIncrement;
      }

      canvas.drawLine(
          Offset(startX, startY),
          Offset(endX, endY),
          Paint()
            ..color = theme.base02Color
            ..strokeWidth = 1);
    }
  }
}
