import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/paint/paint_current_tick_dot.dart';
import 'package:deriv_chart/src/paint/paint_current_tick_label.dart';
import 'package:deriv_chart/src/theme/painting_styles/current_tick_style.dart';
import 'package:flutter/material.dart';

import '../chart_data.dart';
import 'renderable.dart';

// TODO(ramin): We need to eventually remove quoteLabelAreaWidth and use textPainter's width instead
/// Overall horizontal padding for current tick indicator quote label
const double quoteLabelHorizontalPadding = 10;

/// A class to paint common option of [DataSeries] data.
abstract class DataRendererable<S extends DataSeries<Tick>>
    extends Rendererable<S> {
  /// Initializes series for sub-class
  DataRendererable(DataSeries<Tick> series) : super(series);

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

  /// Paints [DataSeries.visibleEntries]
  void onPaintData(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  );
}
