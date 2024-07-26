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
  _ChartFramePainter(this.rightPadding, this.color, this.thickness);

  final double rightPadding;
  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = thickness;

    canvas
      ..drawLine(
        Offset.zero,
        Offset(size.width - rightPadding, 0),
        paint,
      )
      ..drawLine(
        Offset(size.width - rightPadding, 0),
        Offset(size.width - rightPadding, size.height),
        paint,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
