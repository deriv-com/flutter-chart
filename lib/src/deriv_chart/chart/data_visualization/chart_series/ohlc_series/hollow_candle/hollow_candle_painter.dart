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

// TODO(Bahar): Remove the shared code with candle_painter and move them to 
//separate file. 
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

  void _drawWick(Canvas canvas, Color color, OhlcPainting currentPainting) {
    canvas
      ..drawLine(
        Offset(currentPainting.xCenter, currentPainting.yHigh),
        Offset(currentPainting.xCenter, currentPainting.yClose),
        Paint()
          ..color = color
          ..strokeWidth = 1.2,
      )
      ..drawLine(
        Offset(currentPainting.xCenter, currentPainting.yLow),
        Offset(currentPainting.xCenter, currentPainting.yOpen),
        Paint()
          ..color = color
          ..strokeWidth = 1.2,
      );
  }

  void _drawFilledRect(
      Canvas canvas, Color color, OhlcPainting currentPainting) {
    canvas.drawRect(
      Rect.fromLTRB(
        currentPainting.xCenter - currentPainting.width / 2,
        currentPainting.yClose,
        currentPainting.xCenter + currentPainting.width / 2,
        currentPainting.yOpen,
      ),
      Paint()..color = color,
    );
  }

  void _drawHollowRect(
      Canvas canvas, Color color, OhlcPainting currentPainting) {
    canvas.drawRect(
      Rect.fromLTRB(
        currentPainting.xCenter - currentPainting.width / 2,
        currentPainting.yOpen,
        currentPainting.xCenter + currentPainting.width / 2,
        currentPainting.yClose,
      ),
      Paint()
        ..color = color
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawLine(Canvas canvas, Color color, OhlcPainting currentPainting) {
    canvas.drawLine(
      Offset(currentPainting.xCenter - currentPainting.width / 2,
          currentPainting.yOpen),
      Offset(currentPainting.xCenter + currentPainting.width / 2,
          currentPainting.yOpen),
      Paint()
        ..color = color
        ..strokeWidth = 1.2,
    );
  }

  void _paintCandle(
      Canvas canvas, OhlcPainting currentPainting, OhlcPainting prevPainting) {
    final Color _candleColor = currentPainting.yClose > prevPainting.yClose
        ? _negativeColor
        : currentPainting.yClose < prevPainting.yClose
            ? _positiveColor
            : _neutralColor;

    _drawWick(canvas, _candleColor, currentPainting);

    if (currentPainting.yOpen == currentPainting.yClose) {
      _drawLine(canvas, _candleColor, currentPainting);
    } else if (currentPainting.yOpen < currentPainting.yClose) {
      _drawFilledRect(canvas, _candleColor, currentPainting);
    } else {
      _drawHollowRect(canvas, _candleColor, currentPainting);
    }
  }
}
