import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/paint/paint_current_tick_dot.dart';
import 'package:deriv_chart/src/paint/paint_current_tick_label.dart';
import 'package:deriv_chart/src/theme/painting_styles/current_tick_style.dart';
import 'package:flutter/material.dart';

import '../component.dart';

// TODO(ramin): We need to eventually remove quoteLabelAreaWidth and use textPainter's width instead
/// Overall horizontal padding for current tick indicator quote label
const double quoteLabelHorizontalPadding = 10;

/// Base class for Renderables which has a list of entries to paint
/// entries called [visibleEntries] inside the [paint] method
abstract class Rendererable<S extends Series> {
  /// Initializes series for sub-class
  Rendererable(this.series);

  /// The [Series] which this renderable belongs to
  final S series;

  @protected
  int pipSize;

  @protected
  int granularity;

  /// Paints [visibleEntries] on the [canvas]
  void paint({
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    int pipSize,
    int granularity,
  }) {
    if (series.visibleEntries.isEmpty) {
      return;
    }

    this.pipSize = pipSize;
    this.granularity = granularity;

    onPaint(
      canvas: canvas,
      size: size,
      epochToX: epochToX,
      quoteToY: quoteToY,
      animationInfo: animationInfo,
    );

    // Paint current Tick indicator
    if (series?.style?.currentTickStyle != null ?? false) {
      double currentTickX;
      double currentTickY;
      final lastEntry = series.entries.last;
      final CurrentTickStyle currentTickStyle = series.style.currentTickStyle;

      double quoteValue;

      if (series.prevLastEntry != null) {
        currentTickX = lerpDouble(
          epochToX(series.prevLastEntry.epoch),
          epochToX(lastEntry.epoch),
          animationInfo.newTickPercent,
        );

        quoteValue = lerpDouble(
          series.prevLastEntry.quote,
          lastEntry.quote,
          animationInfo.newTickPercent,
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

  /// Paints [visibleEntries]
  void onPaint({
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  });
}
