import 'dart:ui' as ui;

import 'package:deriv_chart/src/logic/chart_series/data_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/candle_painting.dart';
import 'package:deriv_chart/src/theme/painting_styles/candle_style.dart';
import 'package:flutter/material.dart';

import '../../../chart_data.dart';
import 'candle_series.dart';

/// A [DataPainter] for painting CandleStick data.
class CandlePainter extends DataPainter<CandleSeries> {
  /// Initializes
  CandlePainter(CandleSeries series) : super(series);

  Paint _linePaint;
  Paint _positiveCandlePaint;
  Paint _negativeCandlePaint;

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

    final CandleStyle style = series.style ?? theme.candleStyle;

    _linePaint = Paint()
      ..color = style?.lineColor
      ..strokeWidth = 1.2;

    _positiveCandlePaint = Paint()..color = style.positiveColor;

    _negativeCandlePaint = Paint()..color = style.negativeColor;

    final double intervalWidth =
        epochToX(chartConfig.granularity) - epochToX(0);

    final double candleWidth = intervalWidth * 0.6;

    // Painting visible candles except the last one that might be animated.
    for (int i = 0; i < series.visibleEntries.length - 1; i++) {
      final Candle candle = series.visibleEntries[i];

      _paintCandle(
        canvas,
        CandlePainting(
          width: candleWidth,
          xCenter: epochToX(candle.epoch),
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
      final Candle prevLastCandle = series.prevLastEntry;

      final double animatedYClose = quoteToY(ui.lerpDouble(
        prevLastCandle.close,
        lastCandle.close,
        animationInfo.currentTickPercent,
      ));

      final double xCenter = ui.lerpDouble(
        epochToX(prevLastCandle.epoch),
        epochToX(lastCandle.epoch),
        animationInfo.currentTickPercent,
      );

      lastCandlePainting = CandlePainting(
        xCenter: xCenter,
        yHigh: lastCandle.high > prevLastCandle.high
            // In this case we don't update high-low line to avoid instant change of its
            // height (ahead of animation). Candle close value animation will cover the line.
            ? quoteToY(prevLastCandle.high)
            : quoteToY(lastCandle.high),
        yLow: lastCandle.low < prevLastCandle.low
            // Same as comment above.
            ? quoteToY(prevLastCandle.low)
            : quoteToY(lastCandle.low),
        yOpen: quoteToY(lastCandle.open),
        yClose: animatedYClose,
        width: candleWidth,
      );
    } else {
      lastCandlePainting = CandlePainting(
        xCenter: epochToX(lastVisibleCandle.epoch),
        yHigh: quoteToY(lastVisibleCandle.high),
        yLow: quoteToY(lastVisibleCandle.low),
        yOpen: quoteToY(lastVisibleCandle.open),
        yClose: quoteToY(lastVisibleCandle.close),
        width: candleWidth,
      );
    }

    _paintCandle(canvas, lastCandlePainting);
  }

  void _paintCandle(Canvas canvas, CandlePainting cp) {
    canvas.drawLine(
      Offset(cp.xCenter, cp.yHigh),
      Offset(cp.xCenter, cp.yLow),
      _linePaint,
    );

    if (cp.yOpen == cp.yClose) {
      canvas.drawLine(
        Offset(cp.xCenter - cp.width / 2, cp.yOpen),
        Offset(cp.xCenter + cp.width / 2, cp.yOpen),
        _linePaint,
      );
    } else if (cp.yOpen > cp.yClose) {
      canvas.drawRect(
        Rect.fromLTRB(
          cp.xCenter - cp.width / 2,
          cp.yClose,
          cp.xCenter + cp.width / 2,
          cp.yOpen,
        ),
        _positiveCandlePaint,
      );
    } else {
      canvas.drawRect(
        Rect.fromLTRB(
          cp.xCenter - cp.width / 2,
          cp.yOpen,
          cp.xCenter + cp.width / 2,
          cp.yClose,
        ),
        _negativeCandlePaint,
      );
    }
  }
}
