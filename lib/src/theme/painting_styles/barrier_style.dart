import 'package:deriv_chart/src/theme/painting_styles/chart_painting_style.dart';
import 'package:flutter/cupertino.dart';

/// Barrier style
class BarrierStyle extends ChartPaintingStyle {
  /// Initializes
  const BarrierStyle({
    this.color = const Color(0xFF00A79E),
    this.textStyle = const TextStyle(
      fontSize: 10,
      height: 1.3,
      fontWeight: FontWeight.normal,
      color: const Color(0xFF00A79E),
    ),
  });

  /// Color of the barrier
  final Color color;

  /// Style of the title and value
  final TextStyle textStyle;
}
