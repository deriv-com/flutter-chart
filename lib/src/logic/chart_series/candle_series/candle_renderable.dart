import 'dart:ui' as ui;

import 'package:deriv_chart/src/logic/chart_series/base_renderable.dart';
import 'package:deriv_chart/src/logic/chart_series/base_series.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/candle_painting.dart';
import 'package:deriv_chart/src/paint/paint_candles.dart';
import 'package:flutter/material.dart';

/// Line renderable
class CandleRenderable extends BaseRendererable<Candle> {
  /// Initializes
  CandleRenderable(
    BaseSeries<Candle> series,
    List<Candle> visibleEntries,
    Candle prevLastCandle,
  ) : super(series, visibleEntries, prevLastCandle);

  @override
  void onPaint({
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  }) {
    if (visibleEntries.length < 2) {
      return;
    }

    final intervalWidth =
        epochToX(visibleEntries[1].epoch) - epochToX(visibleEntries[0].epoch);
    final candleWidth = intervalWidth * 0.6;

    final List<CandlePainting> candlePaintings = <CandlePainting>[];

    for (int i = 0; i < visibleEntries.length - 1; i++) {
      final Candle candle = visibleEntries[i];

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
    final Candle lastVisibleCandle = visibleEntries.last;

    if (lastCandle == lastVisibleCandle && prevLastEntry != null) {
      final yClose = quoteToY(ui.lerpDouble(
        prevLastEntry.close,
        lastCandle.close,
        animationInfo.newTickPercent,
      ));

      final xCenter = ui.lerpDouble(
        epochToX(prevLastEntry.epoch),
        epochToX(lastCandle.epoch),
        animationInfo.newTickPercent,
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
