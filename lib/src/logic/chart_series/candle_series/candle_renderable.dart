import 'dart:ui' as ui;

import 'package:deriv_chart/src/logic/chart_series/renderable.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/candle_painting.dart';
import 'package:deriv_chart/src/paint/paint_candles.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import 'candle_series.dart';

/// Candle renderable for painting CandleStick data.
class CandleRenderable extends Rendererable<CandleSeries> {
  /// Initializes
  CandleRenderable(CandleSeries series) : super(series);

  @override
  void onPaint({
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  }) {
    if (series.visibleEntries.length < 2) {
      return;
    }

    final double intervalWidth = epochToX(granularity) - epochToX(0);

    final double candleWidth = intervalWidth * 0.6;

    final List<CandlePainting> candlePaintings = <CandlePainting>[];

    for (int i = 0; i < series.visibleEntries.length - 1; i++) {
      final Candle candle = series.visibleEntries[i];

      candlePaintings.add(CandlePainting(
        width: candleWidth,
        xCenter: epochToX(candle.epoch),
        yHigh: quoteToY(candle.high),
        yLow: quoteToY(candle.low),
        yOpen: quoteToY(candle.open),
        yClose: quoteToY(candle.close),
      ));
    }

    // Last visible candle
    final Candle lastCandle = series.entries.last;
    final Candle lastVisibleCandle = series.visibleEntries.last;

    if (lastCandle == lastVisibleCandle && series.prevLastEntry != null) {
      final double yClose = quoteToY(ui.lerpDouble(
        series.prevLastEntry.close,
        lastCandle.close,
        animationInfo.currentTickPercent,
      ));

      final double xCenter = ui.lerpDouble(
        epochToX(series.prevLastEntry.epoch),
        epochToX(lastCandle.epoch),
        animationInfo.currentTickPercent,
      );

      candlePaintings.add(CandlePainting(
        xCenter: xCenter,
        yHigh: quoteToY(lastCandle.high),
        yLow: quoteToY(lastCandle.low),
        yOpen: quoteToY(lastCandle.open),
        yClose: yClose,
        width: candleWidth,
      ));
    } else {
      candlePaintings.add(CandlePainting(
        xCenter: epochToX(lastVisibleCandle.epoch),
        yHigh: quoteToY(lastVisibleCandle.high),
        yLow: quoteToY(lastVisibleCandle.low),
        yOpen: quoteToY(lastVisibleCandle.open),
        yClose: quoteToY(lastVisibleCandle.close),
        width: candleWidth,
      ));
    }

    paintCandles(canvas, candlePaintings, series.style);
  }
}
