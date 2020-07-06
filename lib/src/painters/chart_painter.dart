import 'package:flutter/material.dart';

import '../models/candle.dart';
import '../models/candle_painting.dart';
import '../models/chart_style.dart';

import '../logic/conversion.dart';

import '../paint/paint_candles.dart';
import '../paint/paint_line.dart';

class ChartPainter extends CustomPainter {
  ChartPainter({
    this.candles,
    this.pipSize,
    this.style,
    this.msPerPx,
    this.rightBoundEpoch,
    this.topBoundQuote,
    this.bottomBoundQuote,
    this.topPadding,
    this.bottomPadding,
  });

  final List<Candle> candles;
  final int pipSize;
  final ChartStyle style;

  /// Time axis scale value. Duration in milliseconds of one pixel along the time axis.
  final double msPerPx;

  /// Epoch at x = size.width.
  final int rightBoundEpoch;

  /// Quote at y = [topPadding].
  final double topBoundQuote;

  /// Quote at y = size.height - [bottomPadding].
  final double bottomBoundQuote;

  /// Distance between top edge and [topBoundQuote] in pixels.
  final double topPadding;

  /// Distance between bottom edge and [bottomBoundQuote] in pixels.
  final double bottomPadding;

  Canvas canvas;
  Size size;

  double _epochToX(int epoch) {
    return epochToCanvasX(
      epoch: epoch,
      rightBoundEpoch: rightBoundEpoch,
      canvasWidth: size.width,
      msPerPx: msPerPx,
    );
  }

  double _quoteToY(double quote) {
    return quoteToCanvasY(
      quote: quote,
      topBoundQuote: topBoundQuote,
      bottomBoundQuote: bottomBoundQuote,
      canvasHeight: size.height,
      topPadding: topPadding,
      bottomPadding: bottomPadding,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.length < 2) return;

    this.canvas = canvas;
    this.size = size;

    if (style == ChartStyle.candles) {
      _paintCandles();
    } else {
      _paintLine();
    }

    // _paintNow(); // for testing
  }

  void _paintNow() {
    final x = _epochToX(DateTime.now().millisecondsSinceEpoch);
    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height),
      Paint()..color = Colors.yellow,
    );
  }

  void _paintLine() {
    paintLine(
      canvas,
      size,
      xCoords: candles.map((candle) => _epochToX(candle.epoch)).toList(),
      yCoords: candles.map((candle) => _quoteToY(candle.close)).toList(),
    );
  }

  void _paintCandles() {
    final granularity = candles[1].epoch - candles[0].epoch;
    final candleWidth = msToPx(granularity, msPerPx: msPerPx) * 0.6;

    final candlePaintings = candles.map((candle) {
      return CandlePainting(
        width: candleWidth,
        xCenter: _epochToX(candle.epoch),
        yHigh: _quoteToY(candle.high),
        yLow: _quoteToY(candle.low),
        yOpen: _quoteToY(candle.open),
        yClose: _quoteToY(candle.close),
      );
    }).toList();

    paintCandles(canvas, candlePaintings);
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(ChartPainter oldDelegate) => false;
}
