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

/// Right padding of the chart
const double rightMargin = 5;

/// Background label padding
const double labelPadding = 5;

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

    paintCurrentTickDot(
      canvas,
      center: Offset(currentTickX, currentTickY),
      animationProgress: animationInfo.blinkingPercent,
      style: currentTickStyle,
    );

    final TextSpan span = TextSpan(
      text: quoteValue.toStringAsFixed(pipSize),
      style: currentTickStyle.labelStyle,
    );

    final TextPainter valuePainter = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    final double quoteLabelAreaWidth =
        valuePainter.width + quoteLabelHorizontalPadding;

    final double labelBackgroundRight = size.width - rightMargin;
    final double labelBackgroundLeft =
        labelBackgroundRight - valuePainter.width - labelPadding;

    paintHorizontalDashedLine(
      canvas,
      currentTickX,
      labelBackgroundLeft,
      currentTickY,
      currentTickStyle.color,
      currentTickStyle.lineThickness,
    );

    canvas.drawPath(
      getCurrentTickLabelBackgroundPath(
        left: labelBackgroundLeft,
        top: currentTickY - valuePainter.height / 2 - labelPadding,
        right: labelBackgroundRight,
        bottom: currentTickY + valuePainter.height / 2 + labelPadding,
      ),
      Paint()..color = currentTickStyle.color,
    );

    valuePainter.paint(
      canvas,
      Offset(
        size.width - quoteLabelAreaWidth,
        currentTickY - valuePainter.height / 2,
      ),
    );
  }
}
