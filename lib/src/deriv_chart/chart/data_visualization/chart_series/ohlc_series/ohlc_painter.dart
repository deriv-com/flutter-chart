import 'dart:ui' as ui;

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import '../data_painter.dart';
import '../data_series.dart';
import '../indexed_entry.dart';
import './ohlc_painting.dart';

/// A [DataPainter] for painting CandleStick data which handles the logic for
/// calculation of candle elements for all OHLC type charts
abstract class OhlcPainter extends DataPainter<DataSeries<Candle>> {
  /// Initializes
  OhlcPainter(DataSeries<Candle> series) : super(series);

  @override
  void onPaintData(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  ) {
    if (series.entries == null || series.visibleEntries.length < 2) {
      return;
    }

    final double intervalWidth =
        epochToX(chartConfig.granularity) - epochToX(0);

    final double candleWidth = intervalWidth * 0.6;

    // Painting visible candles except the last one that might be animated.
    for (int i = series.visibleEntries.startIndex;
        i < series.visibleEntries.endIndex - 1;
        i++) {
      final Candle candle = series.entries![i];
      final Candle prevCandle =
          i != 0 ? series.entries![i - 1] : series.entries![0];

      onPaintCandle(
          canvas,
          OhlcPainting(
            width: candleWidth,
            xCenter: epochToX(getEpochOf(candle, i)),
            yHigh: quoteToY(candle.high),
            yLow: quoteToY(candle.low),
            yOpen: quoteToY(candle.open),
            yClose: quoteToY(candle.close),
          ),
          OhlcPainting(
            width: candleWidth,
            xCenter: epochToX(getEpochOf(prevCandle, i - 1)),
            yHigh: quoteToY(prevCandle.high),
            yLow: quoteToY(prevCandle.low),
            yOpen: quoteToY(prevCandle.open),
            yClose: quoteToY(prevCandle.close),
          ));
    }

    // Painting last visible candle
    final Candle lastCandle = series.entries!.last;
    final Candle lastVisibleCandle = series.visibleEntries.last;
    final Candle prevLastCandle = series.entries![series.entries!.length - 2];

    late OhlcPainting lastCandlePainting;
    late OhlcPainting prevLastCandlePainting;

    if (lastCandle == lastVisibleCandle && series.prevLastEntry != null) {
      final IndexedEntry<Candle> prevLastCandle = series.prevLastEntry!;

      final double animatedYClose = quoteToY(ui.lerpDouble(
        prevLastCandle.entry.close,
        lastCandle.close,
        animationInfo.currentTickPercent,
      )!);

      final double xCenter = ui.lerpDouble(
        epochToX(getEpochOf(prevLastCandle.entry, prevLastCandle.index)),
        epochToX(getEpochOf(lastCandle, series.entries!.length - 1)),
        animationInfo.currentTickPercent,
      )!;

      lastCandlePainting = OhlcPainting(
        xCenter: xCenter,
        yHigh: lastCandle.high > prevLastCandle.entry.high
            // In this case we don't update high-low line to avoid instant
            // change of its height (ahead of animation). Candle close value
            // animation will cover the line.
            ? quoteToY(prevLastCandle.entry.high)
            : quoteToY(lastCandle.high),
        yLow: lastCandle.low < prevLastCandle.entry.low
            // Same as comment above.
            ? quoteToY(prevLastCandle.entry.low)
            : quoteToY(lastCandle.low),
        yOpen: quoteToY(lastCandle.open),
        yClose: animatedYClose,
        width: candleWidth,
      );
    } else {
      lastCandlePainting = OhlcPainting(
        xCenter: epochToX(
            getEpochOf(lastVisibleCandle, series.visibleEntries.endIndex - 1)),
        yHigh: quoteToY(lastVisibleCandle.high),
        yLow: quoteToY(lastVisibleCandle.low),
        yOpen: quoteToY(lastVisibleCandle.open),
        yClose: quoteToY(lastVisibleCandle.close),
        width: candleWidth,
      );
    }

    prevLastCandlePainting = OhlcPainting(
      xCenter: epochToX(
          getEpochOf(prevLastCandle, series.visibleEntries.endIndex - 1)),
      yHigh: quoteToY(prevLastCandle.high),
      yLow: quoteToY(prevLastCandle.low),
      yOpen: quoteToY(prevLastCandle.open),
      yClose: quoteToY(prevLastCandle.close),
      width: candleWidth,
    );

    onPaintCandle(canvas, lastCandlePainting, prevLastCandlePainting);
  }

  /// Paints [DataSeries.visibleEntries].
  /// This method is for handling diffrent ways of painting candles for each
  /// chart type
  void onPaintCandle(
    Canvas canvas,
    OhlcPainting currentPainting,
    OhlcPainting prevPainting,
  );
}
