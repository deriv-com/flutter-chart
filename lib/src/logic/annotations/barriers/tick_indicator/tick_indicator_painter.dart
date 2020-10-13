import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/barrier_objects.dart';
import 'package:deriv_chart/src/paint/paint_current_tick_dot.dart';
import 'package:deriv_chart/src/paint/paint_current_tick_label.dart';
import 'package:deriv_chart/src/paint/paint_line.dart';
import 'package:deriv_chart/src/theme/painting_styles/tick_indicator_style.dart';
import 'package:flutter/material.dart';

import 'tick_indicator.dart';

/// Right padding of the chart
const double rightMargin = 5;

/// Background label padding
const double labelPadding = 5;

/// The class to paint last tick indicator on the chart's canvas
class TickIndicatorPainter extends SeriesPainter<TickIndicator> {
  /// Initializes
  TickIndicatorPainter(TickIndicator series) : super(series);

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
    final BarrierObject lastTickObject = series.annotationObject;
    final TickIndicatorStyle style = series.style;

    double quoteValue;

    if (series.previousObject != null) {
      final BarrierObject prevLastTickObject = series.previousObject;
      currentTickX = lerpDouble(
        epochToX(prevLastTickObject.epoch),
        epochToX(lastTickObject.epoch),
        animationInfo.currentTickPercent,
      );

      quoteValue = lerpDouble(
        prevLastTickObject.value,
        lastTickObject.value,
        animationInfo.currentTickPercent,
      );
      currentTickY = quoteToY(quoteValue);
    } else {
      currentTickX = epochToX(lastTickObject.epoch);

      quoteValue = lastTickObject.value;
      currentTickY = quoteToY(quoteValue);
    }

    paintCurrentTickDot(
      canvas,
      center: Offset(currentTickX, currentTickY),
      animationProgress: style.blinking ? animationInfo.blinkingPercent : 0,
      style: style,
    );

    final TextSpan span = TextSpan(
      text: quoteValue.toStringAsFixed(pipSize),
      style: style.labelStyle,
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
        labelBackgroundRight - valuePainter.width - 2 * labelPadding;

    paintHorizontalDashedLine(
      canvas,
      currentTickX,
      labelBackgroundLeft,
      currentTickY,
      style.color,
      style.lineThickness,
    );

    if (style.labelShape == LabelShape.pentagon) {
      canvas.drawPath(
        getCurrentTickLabelBackgroundPath(
          left: labelBackgroundLeft,
          top: currentTickY - valuePainter.height / 2 - labelPadding,
          right: labelBackgroundRight,
          bottom: currentTickY + valuePainter.height / 2 + labelPadding,
        ),
        Paint()..color = style.color,
      );
    } else if (style.labelShape == LabelShape.rectangle) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTRB(
              labelBackgroundLeft,
              currentTickY - valuePainter.height / 2 - labelPadding,
              labelBackgroundRight,
              currentTickY + valuePainter.height / 2 + labelPadding,
            ),
            const Radius.circular(4)),
        Paint()..color = style.color,
      );
    }

    valuePainter.paint(
      canvas,
      Offset(
        size.width - quoteLabelAreaWidth,
        currentTickY - valuePainter.height / 2,
      ),
    );
  }
}
