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

    final candlePaintings = visibleEntries.map((candle) {
      return CandlePainting(
        width: candleWidth,
        xCenter: epochToX(candle.epoch),
        yHigh: quoteToY(candle.high),
        yLow: quoteToY(candle.low),
        yOpen: quoteToY(candle.open),
        yClose: quoteToY(candle.close),
      );
    }).toList();

    paintCandles(canvas, candlePaintings, series.style);
  }
}
