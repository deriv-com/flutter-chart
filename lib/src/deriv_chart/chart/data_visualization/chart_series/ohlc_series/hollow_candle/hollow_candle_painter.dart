import 'dart:ui' as ui;

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/theme/painting_styles/candle_style.dart';
import 'package:flutter/material.dart';

import '../../../chart_data.dart';
import '../../data_painter.dart';
import '../../data_series.dart';
import '../../indexed_entry.dart';
import '../ohlc_painting.dart';

/// A [DataPainter] for painting Hollow CandleStick data.
class HollowCandlePainter extends DataPainter<DataSeries<Candle>> {
  /// Initializes
  HollowCandlePainter(DataSeries<Candle> series) : super(series);

  late Color _positiveColor;
  late Color _negativeColor;
  late Color _neutralColor;

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

    final CandleStyle style = series.style as CandleStyle? ?? theme.candleStyle;

    _positiveColor = style.positiveColor;
    _negativeColor = style.negativeColor;
    _neutralColor = style.neutralColor;

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

      _paintCandle(
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

    _paintCandle(canvas, lastCandlePainting, prevLastCandlePainting);
  }

  void _drawWick(Canvas canvas, Color color, OhlcPainting cp) {
    canvas
      ..drawLine(
        Offset(cp.xCenter, cp.yHigh),
        Offset(cp.xCenter, cp.yClose),
        Paint()
          ..color = color
          ..strokeWidth = 1.2,
      )
      ..drawLine(
        Offset(cp.xCenter, cp.yLow),
        Offset(cp.xCenter, cp.yOpen),
        Paint()
          ..color = color
          ..strokeWidth = 1.2,
      );
  }

  void _drawFilledRect(Canvas canvas, Color color, OhlcPainting cp) {
    canvas.drawRect(
      Rect.fromLTRB(
        cp.xCenter - cp.width / 2,
        cp.yClose,
        cp.xCenter + cp.width / 2,
        cp.yOpen,
      ),
      Paint()..color = color,
    );
  }

  void _drawHollowRect(Canvas canvas, Color color, OhlcPainting cp) {
    canvas.drawRect(
      Rect.fromLTRB(
        cp.xCenter - cp.width / 2,
        cp.yOpen,
        cp.xCenter + cp.width / 2,
        cp.yClose,
      ),
      Paint()
        ..color = color
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawLine(Canvas canvas, Color color, OhlcPainting cp) {
    canvas.drawLine(
      Offset(cp.xCenter - cp.width / 2, cp.yOpen),
      Offset(cp.xCenter + cp.width / 2, cp.yOpen),
      Paint()
        ..color = color
        ..strokeWidth = 1.2,
    );
  }

  void _paintCandle(Canvas canvas, OhlcPainting cp, OhlcPainting pcp) {
    final Color _candleColor = cp.yClose > pcp.yClose
        ? _negativeColor
        : cp.yClose < pcp.yClose
            ? _positiveColor
            : _neutralColor;

    _drawWick(canvas, _candleColor, cp);

    if (cp.yOpen == cp.yClose) {
      _drawLine(canvas, _candleColor, cp);
    } else if (cp.yOpen < cp.yClose) {
      _drawFilledRect(canvas, _candleColor, cp);
    } else {
      _drawHollowRect(canvas, _candleColor, cp);
    }
  }
}
