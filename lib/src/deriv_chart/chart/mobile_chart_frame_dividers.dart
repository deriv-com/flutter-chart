import 'package:flutter/material.dart';

/// A class to draw dividers on the right side of the chart frame.
class MobileChartFrameDividers extends StatelessWidget {
  /// Initializes the dividers on the right side of the chart frame.
  const MobileChartFrameDividers({
    required this.color,
    required this.rightPadding,
    this.sides = const ChartFrameSides.all(value: true),
    this.thickness = 1,
    super.key,
  });

  /// The padding on the right side of the chart frame.
  final double rightPadding;

  /// The color of the dividers.
  final Color color;

  /// The thickness of the dividers.
  final double thickness;

  /// The sides of the chart frame.
  final ChartFrameSides sides;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _ChartFramePainter(rightPadding, color, thickness, sides),
      );
}

class _ChartFramePainter extends CustomPainter {
  _ChartFramePainter(this.rightPadding, this.color, this.thickness, this.sides)
      : _paint = Paint()
          ..color = color
          ..strokeWidth = thickness;

  final double rightPadding;
  final Color color;
  final double thickness;
  final ChartFrameSides sides;

  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    if (sides.top) {
      canvas.drawLine(
        Offset.zero,
        Offset(size.width - rightPadding, 0),
        _paint,
      );
    }

    if (sides.right) {
      canvas.drawLine(
        Offset(size.width - rightPadding, 0),
        Offset(size.width - rightPadding, size.height),
        _paint,
      );
    }

    if (sides.bottom) {
      canvas.drawLine(
        Offset(0, size.height),
        Offset(size.width - rightPadding, size.height),
        _paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A class to define the sides of the chart frame.
class ChartFrameSides {
  /// Initializes the sides of the chart frame.
  const ChartFrameSides({
    this.top = false,
    this.right = false,
    this.bottom = false,
  });

  /// Initializes all sides of the chart frame as true.
  const ChartFrameSides.all({bool value = false})
      : top = value,
        right = value,
        bottom = value;

  /// Top side is visible.
  final bool top;

  /// Right side is visible.
  final bool right;

  /// Bottom side is visible.
  final bool bottom;
}
