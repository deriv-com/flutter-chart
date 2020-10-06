import 'dart:ui';

import 'package:deriv_chart/src/logic/annotations/barriers/vertical_barrier/vertical_barrier.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/barrier_objects.dart';
import 'package:deriv_chart/src/paint/paint_line.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';

/// A class for painting horizontal barriers
class VerticalBarrierPainter extends SeriesPainter<VerticalBarrier> {
  /// Initializes [series]
  VerticalBarrierPainter(VerticalBarrier series) : super(series);

  @override
  void onPaint({
    Canvas canvas,
    Size size,
    epochToX,
    quoteToY,
    AnimationInfo animationInfo,
  }) {
    if (series.isOnRange) {
      final BarrierStyle style = series.style;
      final Paint paint = Paint()
        ..color = Colors.white24
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      int animatedEpoch;

      if (series.previousObject == null) {
        animatedEpoch = series.epoch;
      } else {
        final VerticalBarrierObject prevObject = series.previousObject;
        animatedEpoch = lerpDouble(prevObject.epoch.toDouble(), series.epoch,
                animationInfo.currentTickPercent)
            .toInt();
      }

      final double lineX = epochToX(animatedEpoch);
      final double lineEndY = size.height - 20;

      if (style.isDashed) {
        paintVerticalDashedLine(canvas, lineX, 0, lineEndY, style.color, 1);
      } else {
        canvas.drawLine(Offset(lineX, 0), Offset(lineX, lineEndY), paint);
      }

      // Painting title and value
      final TextPainter titlePainter = TextPainter(
        text: TextSpan(
          text: series.title,
          style: style.textStyle.copyWith(color: style.color),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      titlePainter.paint(
        canvas,
        Offset(lineX - titlePainter.width - 5, lineEndY - titlePainter.height),
      );
    }
  }
}
