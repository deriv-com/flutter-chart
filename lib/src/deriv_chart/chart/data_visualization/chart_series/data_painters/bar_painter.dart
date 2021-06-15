import 'dart:ui' as ui;

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_painters/bar_painting.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/bar_style.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import '../data_painter.dart';
import '../data_series.dart';
import '../indexed_entry.dart';

/// A [DataPainter] for painting Histogram Bar data.
class BarPainter extends DataPainter<DataSeries<Tick>> {
  /// Initializes
  BarPainter(DataSeries<Tick> series) : super(series);

  Paint _positiveHistogramPaint;
  Paint _negativeHistogramPaint;

  @override
  void onPaintData(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  ) {
    if (series.visibleEntries.length < 2) {
      return;
    }

    final BarStyle style = series.style ?? theme.barStyle ?? const BarStyle();

    _positiveHistogramPaint = Paint()..color = style.positiveColor;
    _negativeHistogramPaint = Paint()..color = style.negativeColor;

    final double intervalWidth =
        epochToX(chartConfig.granularity) - epochToX(0);

    final double barWidth = intervalWidth * 0.6;

    // Painting visible bars except the last one that might be animated.
    for (int i = series.visibleEntries.startIndex;
        i < series.visibleEntries.endIndex - 1;
        i++) {
      final Tick tick = series.entries[i];
      final Tick lastTick = series.entries[i - 1 >= 0 ? i - 1 : i];

      // canvas.drawCircle(epochToX(getEpochOf(tick, i)), 10, paint)

      _paintBar(
        canvas,
        BarPainting(
          width: barWidth,
          xCenter: epochToX(getEpochOf(tick, i)),
          yQuote: quoteToY(tick.quote),
        ),
        BarPainting(
          width: barWidth,
          xCenter: epochToX(getEpochOf(lastTick, i)),
          yQuote: quoteToY(lastTick.quote),
        ),
        quoteToY,
      );
    }

    // Painting last visible tick
    final Tick lastTick = series.entries.last;
    final Tick lastVisibleTick = series.visibleEntries.last;

    BarPainting lastTickPainting;

    if (lastTick == lastVisibleTick && series.prevLastEntry != null) {
      final IndexedEntry<Tick> prevLastTick = series.prevLastEntry;

      final double animatedYQuote = quoteToY(ui.lerpDouble(
        prevLastTick.entry.quote,
        lastTick.quote,
        animationInfo.currentTickPercent,
      ));

      final double xCenter = ui.lerpDouble(
        epochToX(getEpochOf(prevLastTick.entry, prevLastTick.index)),
        epochToX(getEpochOf(lastTick, series.entries.length - 1)),
        animationInfo.currentTickPercent,
      );

      lastTickPainting = BarPainting(
        xCenter: xCenter,
        yQuote: animatedYQuote,
        width: barWidth,
      );
    } else {
      lastTickPainting = BarPainting(
        xCenter: epochToX(
            getEpochOf(lastVisibleTick, series.visibleEntries.endIndex - 1)),
        yQuote: quoteToY(lastVisibleTick.quote),
        width: barWidth,
      );
    }

    _paintBar(canvas, lastTickPainting, lastTickPainting, quoteToY);
  }

  void _paintBar(Canvas canvas, BarPainting barPainting,
      BarPainting lastTickPainting, QuoteToY quoteToY) {
    if (barPainting.yQuote > 0) {
      canvas.drawRect(
        Rect.fromLTRB(
          barPainting.xCenter - barPainting.width / 2,
          barPainting.yQuote,
          barPainting.xCenter + barPainting.width / 2,
          quoteToY(0),
        ),
        barPainting.yQuote >= lastTickPainting.yQuote
            ? _positiveHistogramPaint
            : _negativeHistogramPaint,
      );
    } else {
      canvas.drawRect(
        Rect.fromLTRB(
          barPainting.xCenter - barPainting.width / 2,
          quoteToY(0),
          barPainting.xCenter + barPainting.width / 2,
          barPainting.yQuote,
        ),
        barPainting.yQuote >= lastTickPainting.yQuote
            ? _positiveHistogramPaint
            : _negativeHistogramPaint,
      );
    }
  }
}
