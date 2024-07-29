import 'package:flutter/material.dart';

/// A class to draw dividers on the right side of the chart frame.
class MobileChartFrameDividers extends StatelessWidget {
  /// Initializes the dividers on the right side of the chart frame.
  const MobileChartFrameDividers({
    required this.color,
    required this.rightPadding,
    super.key,
    this.thickness = 1,
  });

  /// The padding on the right side of the chart frame.
  final double rightPadding;

  /// The color of the dividers.
  final Color color;

  /// The thickness of the dividers.
  final double thickness;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _ChartFramePainter(rightPadding, color, thickness),
      );
}

class _ChartFramePainter extends CustomPainter {
  _ChartFramePainter(this.rightPadding, this.color, this.thickness)
      : _paint = Paint()
          ..color = color
          ..strokeWidth = thickness;

  final double rightPadding;
  final Color color;
  final double thickness;

  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..drawLine(
        Offset.zero,
        Offset(size.width - rightPadding, 0),
        _paint,
      )
      ..drawLine(
        Offset(size.width - rightPadding, 0),
        Offset(size.width - rightPadding, size.height),
        _paint,
      )
      ..drawLine(
        Offset(0, size.height),
        Offset(size.width - rightPadding, size.height),
        _paint,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
