import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/paint/paint_current_tick_dot.dart';
import 'package:deriv_chart/src/paint/paint_current_tick_label.dart';
import 'package:deriv_chart/src/paint/paint_text.dart';
import 'package:deriv_chart/src/theme/painting_styles/current_tick_style.dart';
import 'package:flutter/material.dart';

import '../chart_data.dart';
import 'series_painter.dart';

/// A class to paint common option of [DataSeries] data.
abstract class DataPainter<S extends DataSeries<Tick>>
    extends SeriesPainter<S> {
  /// Initializes series for sub-class
  DataPainter(DataSeries<Tick> series) : super(series);

  /// Paints [DataSeries.visibleEntries] on the [canvas]
  @override
  void onPaint({
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  }) {
    final DataSeries<Tick> series = this.series;

    if (series.visibleEntries.isEmpty) {
      return;
    }

    onPaintData(canvas, size, epochToX, quoteToY, animationInfo);

    // Paint current Tick indicator
    if (series?.style?.currentTickStyle != null ?? false) {
      double currentTickX;
      double currentTickY;
      final Tick lastEntry = series.entries.last;
      final CurrentTickStyle currentTickStyle = series.style.currentTickStyle;

      double quoteValue;

      if (series.prevLastEntry != null) {
        currentTickX = lerpDouble(
          epochToX(series.prevLastEntry.epoch),
          epochToX(lastEntry.epoch),
          animationInfo.currentTickPercent,
        );

        quoteValue = lerpDouble(
          series.prevLastEntry.quote,
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

        final TextPainter textPainter = makeTextPainter(
          quoteValue.toStringAsFixed(pipSize),
          currentTickStyle.labelStyle,
        );

        paintCurrentTickLabelBackground(
          canvas,
          size,
          centerY: currentTickY,
          width:
              textPainter.width + currentTickStyle.labelHorizontalPadding * 2,
          currentTickX: currentTickX,
          style: currentTickStyle,
        );

        paintWithTextPainter(
          canvas,
          painter: textPainter,
          anchor: Offset(
            size.width - currentTickStyle.labelHorizontalPadding,
            currentTickY,
          ),
          anchorAlignment: Alignment.centerRight,
        );
      }
    }
  }

  /// Paints [DataSeries.visibleEntries]
  void onPaintData(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  );
}
