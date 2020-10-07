import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/barrier_objects.dart';
import 'package:deriv_chart/src/paint/paint_line.dart';
import 'package:deriv_chart/src/paint/paint_text.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';

import 'horizontal_barrier.dart';

/// Padding between lines
const double linesPadding = 4;

/// A class for painting horizontal barriers
class HorizontalBarrierPainter extends SeriesPainter<HorizontalBarrier> {
  /// Initializes [series]
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

      final double valueStartX = paintTextFromRight(
        canvas,
        text: animatedValue.toStringAsFixed(pipSize),
        x: size.width,
        y: y,
        style: style.textStyle.copyWith(
          color: style.color,
          backgroundColor: style.valueBackgroundColor,
        ),
      );

      final double middleLineEndX = valueStartX - linesPadding;
      final double middleLineStartX = middleLineEndX - 12;

      // Painting title and value
      final double titleStartX = paintTextFromRight(
        canvas,
        text: series.title,
        x: middleLineStartX,
        y: y,
        rightPadding: linesPadding,
        style: style.textStyle.copyWith(color: style.color),
      );

      final double mainLineEndX = titleStartX - linesPadding;

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
