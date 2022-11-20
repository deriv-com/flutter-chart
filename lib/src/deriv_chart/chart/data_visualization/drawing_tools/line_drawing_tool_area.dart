// ignore_for_file: cascade_invocations
// canvas.drawLine() returns void, cascade cannot be applied.
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
                child: Container(),
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
        start,
        markerRadius,
        Paint()
          ..color = theme.base02Color
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round,
      );
    } else if (drawingType == 'line') {
      final double xDiff = (end.dx - start.dx).abs();
      final double yDiff = (end.dy - start.dy).abs();
      final double count = xDiff == 0 || yDiff == 0
          ? size.height / max(xDiff, yDiff)
          : size.height / min(xDiff, yDiff);
      double startX = 0;
      double startY = 0;
      double endX = 0;
      double endY = 0;
      final double xStart = start.dx > end.dx ? size.width : 0;
      final double yStart = start.dy > end.dy ? size.height : 0;
      final double xEnd = start.dx < end.dx ? size.width : 0;
      final double yEnd = start.dy < end.dy ? size.height : 0;

      for (int i = 1; i < count; i++) {
        final double xIncrement = start.dx > end.dx ? xDiff * i : -(xDiff * i);
        final double yIncrement = start.dy > end.dy ? yDiff * i : -(yDiff * i);
        startX = start.dy == end.dy ? xStart : start.dx + xIncrement;
        startY = start.dx == end.dx ? yStart : start.dy + yIncrement;
        endX = start.dy == end.dy ? xEnd : end.dx + -xIncrement;
        endY = start.dx == end.dx ? yEnd : end.dy + -yIncrement;
      }
      final Offset _start = Offset(startX, startY);
      final Offset _end = Offset(endX, endY);
      final double yProportionalShift =
          markerRadius * (start.dy - end.dy).abs() / (start.dx - end.dx).abs();
      final double xShift = start.dx == end.dx
          ? 0
          : start.dx > end.dx
              ? -markerRadius
              : markerRadius;
      final double yShift = start.dy == end.dy
          ? 0
          : start.dy > end.dy
              ? -yProportionalShift
              : yProportionalShift;
      canvas.drawLine(
          _start,
          Offset(start.dx - xShift, start.dy - yShift),
          Paint()
            ..color = theme.base02Color
            ..strokeWidth = 1);

      canvas.drawLine(
          Offset(start.dx + xShift, start.dy + yShift),
          Offset(end.dx - xShift, end.dy - yShift),
          Paint()
            ..color = theme.base02Color
            ..strokeWidth = 1);

      canvas.drawLine(
          Offset(end.dx + xShift, end.dy + yShift),
          _end,
          Paint()
            ..color = theme.base02Color
            ..strokeWidth = 1);
    }
  }
}
