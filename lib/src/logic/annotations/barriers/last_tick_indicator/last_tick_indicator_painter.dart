import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/paint/paint_current_tick_dot.dart';
import 'package:deriv_chart/src/paint/paint_current_tick_label.dart';
import 'package:deriv_chart/src/paint/paint_line.dart';
import 'package:deriv_chart/src/theme/painting_styles/current_tick_style.dart';
import 'package:flutter/material.dart';

import 'last_tick_indicator.dart';

/// The class to paint last tick indicator on the chart's canvas
class LastTickIndicatorPainter extends SeriesPainter<LastTickIndicator> {
  /// Initializes
  LastTickIndicatorPainter(LastTickIndicator series) : super(series);

  @override
  void onPaint({
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  }) {
    double currentTickX;
    double currentTickY;
    final LastTickObject lastTickObject = series.annotationObject;
    final Tick lastEntry = lastTickObject.tick;
    final CurrentTickStyle currentTickStyle = series.style;

    double quoteValue;

    if (series.previousObject != null) {
      final LastTickObject prevLastTickObject = series.previousObject;
      currentTickX = lerpDouble(
        epochToX(prevLastTickObject.tick.epoch),
        epochToX(lastEntry.epoch),
        animationInfo.currentTickPercent,
      );

      quoteValue = lerpDouble(
        prevLastTickObject.tick.quote,
        lastEntry.quote,
        animationInfo.currentTickPercent,
      );
      currentTickY = quoteToY(quoteValue);
    } else {
      currentTickX = epochToX(lastEntry.epoch);

      quoteValue = lastEntry.quote;
      currentTickY = quoteToY(quoteValue);
    }

    if (!currentTickX.isNaN && !currentTickY.isNaN) {
      paintCurrentTickDot(
        canvas,
        center: Offset(currentTickX, currentTickY),
        animationProgress: animationInfo.blinkingPercent,
        style: currentTickStyle,
      );

      paintHorizontalDashedLine(
        canvas,
        currentTickX,
        size.width,
        currentTickY,
        currentTickStyle.color,
        currentTickStyle.lineThickness,
      );

      final TextSpan span = TextSpan(
        text: quoteValue.toStringAsFixed(pipSize),
        style: currentTickStyle.labelStyle,
      );

      final TextPainter textPainter = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final double quoteLabelAreaWidth =
          textPainter.width + quoteLabelHorizontalPadding;

      paintCurrentTickLabelBackground(
        canvas,
        size,
        centerY: currentTickY,
        quoteLabelsAreaWidth: quoteLabelAreaWidth,
        quoteLabel: lastEntry.quote.toStringAsFixed(4),
        currentTickX: currentTickX,
        style: currentTickStyle,
      );

      textPainter.paint(
        canvas,
        Offset(size.width - quoteLabelAreaWidth,
            currentTickY - textPainter.height / 2),
      );
    }
  }
}
