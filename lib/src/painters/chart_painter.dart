import 'package:deriv_chart/src/theme/painting_styles/candle_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/chart_paiting_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../models/candle.dart';
import '../models/candle_painting.dart';

import '../paint/paint_candles.dart';
import '../paint/paint_line.dart';

class ChartPainter extends CustomPainter {
  ChartPainter({
    this.candles,
    this.pipSize,
    this.granularity,
    this.style,
    this.epochToCanvasX,
    this.quoteToCanvasY,
  });

  final List<Candle> candles;
  final int pipSize;
  final int granularity;
  final ChartPaintingStyle style;

  final double Function(int) epochToCanvasX;
  final double Function(double) quoteToCanvasY;

  Canvas canvas;
  Size size;

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.length < 2) return;

    this.canvas = canvas;
    this.size = size;

    if (style is CandleStyle) {
      _paintCandles(style);
    } else if (style is LineStyle) {
      _paintLine(style);
    }
  }

  void _paintLine(LineStyle lineStyle) {
    paintLine(
      canvas,
      size,
      xCoords: candles.map((candle) => epochToCanvasX(candle.epoch)).toList(),
      yCoords: candles.map((candle) => quoteToCanvasY(candle.close)).toList(),
      style: lineStyle,
    );
  }

  void _paintCandles(CandleStyle candleStyle) {
    final intervalWidth = epochToCanvasX(granularity) - epochToCanvasX(0);
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

    paintCandles(canvas, candlePaintings, candleStyle);
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(ChartPainter oldDelegate) => false;
}
