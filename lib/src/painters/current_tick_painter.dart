import 'package:deriv_chart/src/theme/painting_styles/current_tick_style.dart';
import 'package:flutter/material.dart';

import '../models/tick.dart';

import '../paint/paint_current_tick_dot.dart';
import '../paint/paint_current_tick_label.dart';

class CurrentTickPainter extends CustomPainter {
  CurrentTickPainter({
    @required this.animatedCurrentTick,
    @required this.blinkAnimationProgress,
    @required this.quoteLabelsAreaWidth,
    @required this.pipSize,
    @required this.epochToCanvasX,
    @required this.quoteToCanvasY,
    @required this.style,
  });

  final Tick animatedCurrentTick;
  final double blinkAnimationProgress;
  final double quoteLabelsAreaWidth;
  final int pipSize;
  final double Function(int) epochToCanvasX;
  final double Function(double) quoteToCanvasY;

  final CurrentTickStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    if (animatedCurrentTick == null) return;

    paintCurrentTickDot(
      canvas,
      center: Offset(
        epochToCanvasX(animatedCurrentTick.epoch),
        quoteToCanvasY(animatedCurrentTick.quote),
      ),
      animationProgress: blinkAnimationProgress,
      style: style,
    );

    paintCurrentTickLabel(
      canvas,
      size,
      centerY: quoteToCanvasY(animatedCurrentTick.quote),
      quoteLabel: animatedCurrentTick.quote.toStringAsFixed(pipSize),
      quoteLabelsAreaWidth: quoteLabelsAreaWidth,
      currentTickX: epochToCanvasX(animatedCurrentTick.epoch),
      style: style,
    );
  }

  @override
  bool shouldRepaint(CurrentTickPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(CurrentTickPainter oldDelegate) => false;
}
