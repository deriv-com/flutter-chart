import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_series/base_series.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/paint/paint_current_tick_dot.dart';
import 'package:deriv_chart/src/paint/paint_current_tick_label.dart';
import 'package:deriv_chart/src/theme/painting_styles/current_tick_style.dart';
import 'package:flutter/material.dart';

typedef EpochToX = double Function(int);
typedef QuoteToY = double Function(double);

// TODO(ramin): We need to eventually remove quoteLabelAreaWidth and use textPainter's width instead
/// Overall horizontal padding for current tick indicator quote label
const double quoteLabelHorizontalPadding = 10;

/// Base class for Renderables which has a list of entries to paint
/// entries called [visibleEntries] inside the [paint] method
abstract class BaseRendererable<T extends Tick> {
  /// Initializes
  BaseRendererable(
    this.series,
    this.visibleEntries,
    this.prevLastEntry,
  );

  /// Visible entries of [series] inside the frame
  final List<T> visibleEntries;

  /// Previous last entry
  final T prevLastEntry;

  /// The [BaseSeries] which this renderable belongs to
  final BaseSeries<T> series;

  /// Paints [visibleEntries] on the [canvas]
  void paint({
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    int pipSize,
  }) {
    if (visibleEntries.isEmpty) {
      return;
    }
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
      final T lastEntry = series.entries.last;
      final CurrentTickStyle currentTickStyle = series.style.currentTickStyle;

      double quoteValue;

      if (prevLastEntry != null) {
        currentTickX = lerpDouble(
          epochToX(prevLastEntry.epoch),
          epochToX(lastEntry.epoch),
          animationInfo.newTickPercent,
        );

        quoteValue = lerpDouble(
          prevLastEntry.quote,
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
