import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/paint/paint_line.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';

import 'horizontal_barrier.dart';

/// Padding between lines
const double linesPadding = 4;

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
      final BarrierStyle style = series.style;

      Paint paint = Paint()
        ..color = style.color
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
        style: style.textStyle.copyWith(color: style.color),
      );

      final TextPainter valuePainter = TextPainter(
        text: valueTextSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final double valueStartX = size.width - valuePainter.width - 10;
      final double middleLineEndX = valueStartX - linesPadding;
      final double middleLineStartX = middleLineEndX - 12;

      valuePainter.paint(
        canvas,
        Offset(valueStartX, y - valuePainter.height / 2),
      );

      // Painting title and value
      final TextPainter titlePainter = TextPainter(
        text: TextSpan(
          text: series.title,
          style: style.textStyle.copyWith(color: style.color),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final double titleEndX = middleLineStartX - linesPadding;
      final double titleStartX = titleEndX - titlePainter.width;
      final double mainLineEndX = titleStartX - linesPadding;

      titlePainter.paint(
        canvas,
        Offset(titleStartX, y - titlePainter.height / 2),
      );

      // Painting main line
      if (style.isDashed) {
        paintHorizontalDashedLine(canvas, 0, mainLineEndX, y, style.color, 1);
      } else {
        canvas.drawLine(Offset(0, y), Offset(mainLineEndX, y), paint);
      }

      // Painting middle line
      canvas.drawLine(
        Offset(middleLineStartX, y),
        Offset(middleLineEndX, y),
        paint,
      );
    }
  }
}
