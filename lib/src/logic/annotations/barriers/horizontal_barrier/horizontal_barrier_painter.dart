import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:flutter/material.dart';

import 'horizontal_barrier.dart';

class HorizontalBarrierPainter extends SeriesPainter<HorizontalBarrier> {
  HorizontalBarrierPainter(HorizontalBarrier series) : super(series);

  @override
  void onPaint({
    Canvas canvas,
    Size size,
    epochToX,
    quoteToY,
    AnimationInfo animationInfo,
  }) {
    if (series.isOnRange) {
      Paint paint = Paint()
        ..color = const Color(0xFF00A79E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      double animatedValue;

      if (series.previousObject == null) {
        animatedValue = series.value;
      } else {
        final HorizontalBarrierObject previousBarrier = series.previousObject;
        animatedValue = lerpDouble(
          previousBarrier.value,
          series.value,
          animationInfo.currentTickPercent,
        );
      }

      final double y = quoteToY(animatedValue);

      final TextSpan valueTextSpan = TextSpan(
        text: animatedValue.toStringAsFixed(pipSize),
        style: const TextStyle(
          fontSize: 10,
          height: 1.3,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF00A79E),
        ),
      );

      final TextPainter valuePainter = TextPainter(
        text: valueTextSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final double valueStartX = size.width - valuePainter.width - 10;
      final double titleEndX = valueStartX - 12 - 5;

      valuePainter.paint(
        canvas,
        Offset(valueStartX, y - valuePainter.height / 2),
      );

      final TextPainter titlePainter = TextPainter(
        text: TextSpan(
          text: series.title,
          style: const TextStyle(
            fontSize: 10,
            height: 1.3,
            fontWeight: FontWeight.normal,
            color: const Color(0xFF00A79E),
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final double titleStartX = titleEndX - titlePainter.width;
      final double mainLineEndX = titleStartX - 5;

      titlePainter.paint(
          canvas, Offset(titleStartX, y - titlePainter.height / 2));

      canvas.drawLine(Offset(0, y), Offset(mainLineEndX, y), paint);
      canvas.drawLine(Offset(titleEndX, y), Offset(valueStartX, y), paint);
    }
  }
}
