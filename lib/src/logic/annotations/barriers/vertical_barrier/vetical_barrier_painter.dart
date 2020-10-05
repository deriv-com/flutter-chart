import 'dart:ui';

import 'package:deriv_chart/src/logic/annotations/barriers/vertical_barrier/vertical_barrier.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/paint/paint_current_tick_label.dart';
import 'package:deriv_chart/src/paint/paint_line.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';

class VerticalBarrierPainter extends SeriesPainter<VerticalBarrier> {
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

      if (style.isDashed) {
        paintVerticalDashedLine(canvas, lineX, 0, size.height, style.color, 1);
      } else {
        canvas.drawLine(Offset(lineX, 0), Offset(lineX, size.height), paint);
      }
    }
  }
}
