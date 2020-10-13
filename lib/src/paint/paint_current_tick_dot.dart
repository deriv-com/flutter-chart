import 'package:deriv_chart/src/theme/painting_styles/tick_indicator_style.dart';
import 'package:flutter/material.dart';

void paintCurrentTickDot(
  Canvas canvas, {
  @required Offset center,
  @required double animationProgress,
  @required TickIndicatorStyle style,
}) {
  canvas.drawCircle(
    center,
    12 * animationProgress,
    Paint()..color = style.color.withAlpha(50),
  );
  canvas.drawCircle(
    center,
    3,
    Paint()..color = style.color,
  );
}
