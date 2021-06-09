import 'dart:ui' as ui;

import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/data_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/indexed_entry.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/bar_style.dart';
import 'package:flutter/material.dart';

import '../data_series.dart';

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
      final Candle candle = series.entries[i];

      _paintCandle(
        canvas,
        CandlePainting(
          width: barWidth,
          xCenter: epochToX(getEpochOf(candle, i)),
          yHigh: quoteToY(candle.high),
          yLow: quoteToY(candle.low),
          yOpen: quoteToY(candle.open),
          yClose: quoteToY(candle.close),
        ),
      );
    }

    // Painting last visible candle
    final Candle lastCandle = series.entries.last;
    final Candle lastVisibleCandle = series.visibleEntries.last;

    CandlePainting lastCandlePainting;

    if (lastCandle == lastVisibleCandle && series.prevLastEntry != null) {
      final IndexedEntry<Candle> prevLastCandle = series.prevLastEntry;

      final double animatedYClose = quoteToY(ui.lerpDouble(
        prevLastCandle.entry.close,
        lastCandle.close,
        animationInfo.currentTickPercent,
      ));

      final double xCenter = ui.lerpDouble(
        epochToX(getEpochOf(prevLastCandle.entry, prevLastCandle.index)),
        epochToX(getEpochOf(lastCandle, series.entries.length - 1)),
        animationInfo.currentTickPercent,
      );

      lastCandlePainting = CandlePainting(
        xCenter: xCenter,
        yHigh: lastCandle.high > prevLastCandle.entry.high
            // In this case we don't update high-low line to avoid instant change of its
            // height (ahead of animation). Candle close value animation will cover the line.
            ? quoteToY(prevLastCandle.entry.high)
            : quoteToY(lastCandle.high),
        yLow: lastCandle.low < prevLastCandle.entry.low
            // Same as comment above.
            ? quoteToY(prevLastCandle.entry.low)
            : quoteToY(lastCandle.low),
        yOpen: quoteToY(lastCandle.open),
        yClose: animatedYClose,
        width: barWidth,
      );
    } else {
      lastCandlePainting = CandlePainting(
        xCenter: epochToX(
            getEpochOf(lastVisibleCandle, series.visibleEntries.endIndex - 1)),
        yHigh: quoteToY(lastVisibleCandle.high),
        yLow: quoteToY(lastVisibleCandle.low),
        yOpen: quoteToY(lastVisibleCandle.open),
        yClose: quoteToY(lastVisibleCandle.close),
        width: barWidth,
      );
    }

    _paintCandle(canvas, lastCandlePainting);
  }

  void _paintCandle(Canvas canvas, CandlePainting cp) {
    if (cp.yOpen > cp.yClose) {
      canvas.drawRect(
        Rect.fromLTRB(
          cp.xCenter - cp.width / 2,
          cp.yClose,
          cp.xCenter + cp.width / 2,
          cp.yOpen,
        ),
        _positiveHistogramPaint,
      );
    } else {
      canvas.drawRect(
        Rect.fromLTRB(
          cp.xCenter - cp.width / 2,
          cp.yOpen,
          cp.xCenter + cp.width / 2,
          cp.yClose,
        ),
        _negativeHistogramPaint,
      );
    }
  }
}
