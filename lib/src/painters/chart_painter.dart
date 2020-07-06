import 'package:flutter/material.dart';

import '../models/candle.dart';
import '../models/candle_painting.dart';
import '../models/chart_style.dart';

import '../paint/paint_candles.dart';
import '../paint/paint_line.dart';

class ChartPainter extends CustomPainter {
  ChartPainter({
    this.candles,
    this.pipSize,
    this.style,
    this.epochToCanvasX,
    this.quoteToCanvasY,
  });

  final List<Candle> candles;
  final int pipSize;
  final ChartStyle style;

  final double Function(int) epochToCanvasX;
  final double Function(double) quoteToCanvasY;

  Canvas canvas;
  Size size;

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
    final x = epochToCanvasX(DateTime.now().millisecondsSinceEpoch);
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
      xCoords: candles.map((candle) => epochToCanvasX(candle.epoch)).toList(),
      yCoords: candles.map((candle) => quoteToCanvasY(candle.close)).toList(),
    );
  }

  void _paintCandles() {
    final intervalWidth =
        epochToCanvasX(candles[1].epoch) - epochToCanvasX(candles[0].epoch);
    final candleWidth = intervalWidth * 0.6;

    final candlePaintings = candles.map((candle) {
      return CandlePainting(
        width: candleWidth,
        xCenter: epochToCanvasX(candle.epoch),
        yHigh: quoteToCanvasY(candle.high),
        yLow: quoteToCanvasY(candle.low),
        yOpen: quoteToCanvasY(candle.open),
        yClose: quoteToCanvasY(candle.close),
      );
    }).toList();

    paintCandles(canvas, candlePaintings);
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(ChartPainter oldDelegate) => false;
}
