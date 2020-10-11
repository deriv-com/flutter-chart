import 'dart:ui';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/annotations/barriers/barrier.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/barrier_objects.dart';
import 'package:deriv_chart/src/models/chart_object.dart';
import 'package:deriv_chart/src/paint/paint_current_tick_dot.dart';
import 'package:deriv_chart/src/paint/paint_current_tick_label.dart';
import 'package:deriv_chart/src/paint/paint_line.dart';
import 'package:flutter/material.dart';

class LastTickObject extends BarrierObject {
  LastTickObject(this.tick)
      : super(
          tick.epoch,
          tick.epoch,
          tick.quote,
          tick.quote,
        );

  final Tick tick;
}

class LastTickIndicator extends Barrier {
  LastTickIndicator(this.tick);

  final Tick tick;

  @override
  BarrierObject createObject() => LastTickObject(tick);

  @override
  SeriesPainter<Series> createPainter() => LastTickIndicatorPainter(this);

  @override
  List<double> recalculateMinMax() => <double>[double.nan, double.nan];
}

class LastTickIndicatorPainter extends SeriesPainter<LastTickIndicator> {
  LastTickIndicatorPainter(LastTickIndicator series) : super(series);

  @override
  void onPaint({
    Canvas canvas,
    Size size,
    epochToX,
    quoteToY,
    AnimationInfo animationInfo,
  }) {
    double currentTickX;
    double currentTickY;
    final Tick lastEntry = (series.annotationObject as LastTickObject).tick;
    final CurrentTickStyle currentTickStyle = CurrentTickStyle();

    double quoteValue;

    if (series.previousObject != null) {
      currentTickX = lerpDouble(
        epochToX((series.previousObject as LastTickObject).tick.epoch),
        epochToX(lastEntry.epoch),
        animationInfo.currentTickPercent,
      );

      quoteValue = lerpDouble(
        (series.previousObject as LastTickObject).tick.quote,
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
