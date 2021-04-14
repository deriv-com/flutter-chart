import 'dart:math';
import 'dart:ui';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/annotations/barriers/horizontal_barrier/horizontal_barrier_painter.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/barrier_objects.dart';
import 'package:deriv_chart/src/paint/paint_text.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';

import 'horizontal_barrier.dart';

/// A class for painting horizontal barriers.
class CandleIndicatorPainter extends HorizontalBarrierPainter<CandleIndicator> {
  /// Initializes [series].
  CandleIndicatorPainter(
    CandleIndicator series,
  ) : super(series);

  Paint _paint;

  /// Padding between lines.
  static const double padding = 4;

  /// Right margin.
  static const double rightMargin = 4;

  @override
  void onPaint({
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  }) {
    if (!series.isOnRange) {
      return;
    }

    final HorizontalBarrierStyle style = series.style ??
        theme.horizontalBarrierStyle ??
        const HorizontalBarrierStyle();

    _paint = Paint()
      ..strokeWidth = 1
      ..color = style.secondaryBackgroundColor;

    double animatedValue;

    // If previous object is null then its first load and no need to perform
    // transition animation from previousObject to new object.
    if (series.previousObject == null) {
      animatedValue = series.value;
    } else {
      final BarrierObject previousBarrier = series.previousObject;
      // Calculating animated values regarding `currentTickPercent` in transition animation
      // from previousObject to new object
      animatedValue = lerpDouble(
        previousBarrier.value,
        series.value,
        animationInfo.currentTickPercent,
      );
    }

    double y = quoteToY(animatedValue);

    if (series.visibility ==
        HorizontalBarrierVisibility.keepBarrierLabelVisible) {
      final double labelHalfHeight = style.labelHeight / 2;

      if (y - labelHalfHeight < 0) {
        y = labelHalfHeight;
      } else if (y + labelHalfHeight > size.height) {
        y = size.height - labelHalfHeight;
      }
    }

    final TextPainter valuePainter = makeTextPainter(
      animatedValue.toStringAsFixed(chartConfig.pipSize),
      style.textStyle,
    );

    String timerString = '00:00';

    timerString = durationToString(series?.timerDuration ?? const Duration());

    final TextPainter timerPainter = makeTextPainter(
      timerString,
      style.textStyle,
    );

    final double timerWidth =
        max<double>(timerPainter.width, valuePainter.width);

    final Rect labelArea = Rect.fromCenter(
      center: Offset(size.width - rightMargin - padding - timerWidth / 2,
          y + style.labelHeight - 3),
      width: valuePainter.width + padding * 2,
      height: style.labelHeight + 3,
    );

    // Label.
    paintLabelBackground(
      canvas,
      labelArea,
      LabelShape.rectangle,
      _paint,
    );
    paintWithTextPainter(
      canvas,
      painter: timerPainter,
      anchor: labelArea.center,
    );

    super.onPaint(
      canvas: canvas,
      size: size,
      epochToX: epochToX,
      quoteToY: quoteToY,
      animationInfo: animationInfo,
    );
  }
}
