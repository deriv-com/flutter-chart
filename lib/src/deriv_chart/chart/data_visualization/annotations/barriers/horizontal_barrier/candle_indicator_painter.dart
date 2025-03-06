import 'dart:math';
import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/barrier_objects.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/helper_functions.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';

import 'horizontal_barrier.dart';
import 'horizontal_barrier_painter.dart';
import 'tick_indicator.dart';

/// A class for painting candle indicators.
class CandleIndicatorPainter extends HorizontalBarrierPainter<CandleIndicator> {
  /// Initializes [series].
  CandleIndicatorPainter(
    CandleIndicator series,
  ) : super(series);

  late Paint _paint;

  /// Padding between lines.
  static const double padding = 4;

  /// Right margin.
  static const double rightMargin = 4;

  @override
  void onPaint({
    required Canvas canvas,
    required Size size,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
    required AnimationInfo animationInfo,
    required ChartConfig chartConfig,
    required ChartScaleModel chartScaleModel,
  }) {
    if (!series.isOnRange) {
      return;
    }

    if (series.showTimer) {
      _paintTimer(
        canvas,
        size,
        quoteToY,
        animationInfo,
      );
    }

    super.onPaint(
      canvas: canvas,
      size: size,
      epochToX: epochToX,
      quoteToY: quoteToY,
      animationInfo: animationInfo,
      chartConfig: chartConfig,
      chartScaleModel: chartScaleModel,
    );
  }

  void _paintTimer(
    Canvas canvas,
    Size size,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  ) {
    final HorizontalBarrierStyle style =
        series.style as HorizontalBarrierStyle? ?? theme.horizontalBarrierStyle;

    _paint = Paint()
      ..strokeWidth = 1
      ..color = style.secondaryBackgroundColor;

    late double animatedValue;

    // If previous object is null then its first load and no need to perform
    // transition animation from previousObject to new object.
    if (series.previousObject == null) {
      animatedValue = series.quote!;
    } else {
      final BarrierObject previousBarrier = series.previousObject!;
      // Calculating animated values regarding `currentTickPercent` in
      // transition animation from previousObject to new object
      animatedValue = lerpDouble(
        previousBarrier.quote!,
        series.quote!,
        animationInfo.currentTickPercent,
      )!;
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

    String timerString = '--:--';

    if (series.timerDuration != null) {
      timerString = durationToString(series.timerDuration ?? const Duration());
    }

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
  }
}
