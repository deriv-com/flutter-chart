import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

/// An abstract custom painter to paint a highlighted element at the crosshair position.
///
/// This serves as the base class for all series-specific highlight painters.
abstract class CrosshairHighlightPainter extends CustomPainter {
  /// Initializes a custom painter to paint a highlighted element.
  const CrosshairHighlightPainter({
    required this.tick,
    required this.quoteToY,
    required this.xCenter,
  });

  /// The tick to highlight.
  final Tick tick;

  /// Function to convert quote to Y coordinate.
  final double Function(double) quoteToY;

  /// The X center position of the element.
  final double xCenter;

  @override
  bool shouldRepaint(CrosshairHighlightPainter oldDelegate) =>
      oldDelegate.tick != tick || oldDelegate.xCenter != xCenter;
}
