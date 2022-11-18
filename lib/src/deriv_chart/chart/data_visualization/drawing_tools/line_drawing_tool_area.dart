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
  bool _isPenDown = false;

  /// tapped position
  Offset? position;

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
  }

  void _onTap(TapUpDetails details) {
    setState(() {
      position = details.localPosition;
      if (!_isPenDown) {
        _isPenDown = true;
      } else {
        _isPenDown = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) => Stack(children: <Widget>[
        position?.dx != null && position?.dy != null
            ? CustomPaint(
                painter: _LineDrawingToolPainter(
                x: position?.dx,
                y: position?.dy,
                theme: context.watch<ChartTheme>(),
              ))
            : Container()
      ]);
}

class _LineDrawingToolPainter extends CustomPainter {
  _LineDrawingToolPainter({
    required this.x,
    required this.y,
    required this.theme,
  });

  final double? x;
  final double? y;
  final ChartTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(x!, y!);

    canvas.drawCircle(
      center,
      4,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_LineDrawingToolPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_LineDrawingToolPainter oldDelegate) => false;
}
