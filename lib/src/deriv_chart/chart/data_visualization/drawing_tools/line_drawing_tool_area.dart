import 'dart:math';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
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

  /// canvas size;
  Size? _canvasSize;

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

        /// calculations for drawing a line across 2 markers;
        double startX = 0, startY = 0, endX = 0, endY = 0;
        final double xDiff = (center.dx - _startingPoint!.dx).abs();
        final double yDiff = (center.dy - _startingPoint!.dy).abs();
        final double diagonal =
            sqrt(pow(_canvasSize!.height, 2) + pow(_canvasSize!.width, 2));
        final double count = xDiff == 0 || yDiff == 0
            ? diagonal / max(xDiff, yDiff)
            : diagonal / min(xDiff, yDiff);
        for (int i = 1; i < count; i++) {
          final double xIncrement =
              _startingPoint!.dx > center.dx ? xDiff * i : -(xDiff * i);
          final double yIncrement =
              _startingPoint!.dy > center.dy ? yDiff * i : -(yDiff * i);
          startX = _startingPoint!.dx + xIncrement;
          startY = _startingPoint!.dy + yIncrement;
          endX = center.dx + -xIncrement;
          endY = center.dy + -yIncrement;
        }

        _lineDrawings.addAll(<LineDrawingTool>[
          ..._lineDrawings,
          LineDrawingTool(drawingType: 'marker', start: center),
          LineDrawingTool(
            drawingType: 'line',
            start: Offset(startX, startY),
            end: Offset(endX, endY),
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
                    onPaint: (Size size) {
                      _canvasSize = size;
                    }))
            : Container()
      ]);
}

class _LineDrawingToolPainter extends CustomPainter {
  _LineDrawingToolPainter({
    required this.lineDrawings,
    required this.theme,
    required this.onPaint,
  });

  final List<LineDrawingTool> lineDrawings;
  final ChartTheme theme;
  void Function(Size size) onPaint;

  @override
  void paint(Canvas canvas, Size size) {
    lineDrawings.asMap().forEach((int index, LineDrawingTool element) {
      element.onPaint(canvas, size, theme);
      onPaint(size);
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
      canvas.drawLine(
          start,
          end,
          Paint()
            ..color = theme.base02Color
            ..strokeWidth = 1);
    }
  }
}
