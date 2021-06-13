import 'dart:ui' as ui;

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_painters/bar_painting.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/models/candle.dart';
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
      final Candle candle = series.entries[i];
      final Candle lastCandle = series.entries[i - 1 >= 0 ? i - 1 : i];

      _paintBar(
        canvas,
        BarPainting(
          width: barWidth,
          xCenter: epochToX(getEpochOf(candle, i)),
          yQuote: candle.quote,
        ),
        BarPainting(
          width: barWidth,
          xCenter: epochToX(getEpochOf(candle, i)),
          yQuote: lastCandle.quote,
        ),
      );
    }

    // Painting last visible candle
    final Candle lastCandle = series.entries.last;
    final Candle lastVisibleCandle = series.visibleEntries.last;

    BarPainting lastCandlePainting;

    if (lastCandle == lastVisibleCandle && series.prevLastEntry != null) {
      final IndexedEntry<Candle> prevLastCandle = series.prevLastEntry;

      final double animatedYQuote = quoteToY(ui.lerpDouble(
        prevLastCandle.entry.quote,
        lastCandle.quote,
        animationInfo.currentTickPercent,
      ));

      final double xCenter = ui.lerpDouble(
        epochToX(getEpochOf(prevLastCandle.entry, prevLastCandle.index)),
        epochToX(getEpochOf(lastCandle, series.entries.length - 1)),
        animationInfo.currentTickPercent,
      );

      lastCandlePainting = BarPainting(
        xCenter: xCenter,
        yQuote: animatedYQuote,
        width: barWidth,
      );
    } else {
      lastCandlePainting = BarPainting(
        xCenter: epochToX(
            getEpochOf(lastVisibleCandle, series.visibleEntries.endIndex - 1)),
        yQuote: quoteToY(lastVisibleCandle.quote),
        width: barWidth,
      );
    }

    _paintBar(canvas, lastCandlePainting, lastCandlePainting);
  }

  void _paintBar(
      Canvas canvas, BarPainting barPainting, BarPainting lastCandlePainting) {
    if (barPainting.yQuote > 0) {
      canvas.drawRect(
        Rect.fromLTRB(
          barPainting.xCenter - barPainting.width / 2,
          barPainting.yQuote,
          barPainting.xCenter + barPainting.width / 2,
          0,
        ),
        barPainting.yQuote >= lastCandlePainting.yQuote
            ? _positiveHistogramPaint
            : _negativeHistogramPaint,
      );
    } else {
      canvas.drawRect(
        Rect.fromLTRB(
          barPainting.xCenter - barPainting.width / 2,
          0,
          barPainting.xCenter + barPainting.width / 2,
          barPainting.yQuote,
        ),
        barPainting.yQuote >= lastCandlePainting.yQuote
            ? _positiveHistogramPaint
            : _negativeHistogramPaint,
      );
    }
  }
}
