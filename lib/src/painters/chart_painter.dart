import 'package:deriv_chart/src/logic/chart_series/base_series.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/theme/painting_styles/chart_paiting_style.dart';
import 'package:flutter/material.dart';

class ChartPainter extends CustomPainter {
  ChartPainter({
    this.pipSize,
    this.style,
    this.mainSeries,
    this.animationInfo,
    this.epochToCanvasX,
    this.quoteToCanvasY,
  });

  final int pipSize;
  final ChartPaintingStyle style;

  final double Function(int) epochToCanvasX;
  final double Function(double) quoteToCanvasY;

  final AnimationInfo animationInfo;

  Canvas canvas;
  Size size;

  final BaseSeries mainSeries;

  @override
  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;
    this.size = size;

    mainSeries.paint(
      canvas,
      size,
      epochToCanvasX,
      quoteToCanvasY,
      animationInfo,
    );
  }

//  void _paintLine(LineStyle lineStyle) {
//    paintLine(
//      canvas,
//      size,
//      xCoords: candles.map((candle) => epochToCanvasX(candle.epoch)).toList(),
//      yCoords: candles.map((candle) => quoteToCanvasY(candle.close)).toList(),
//      style: lineStyle,
//    );
//  }
//
//  void _paintCandles(CandleStyle candleStyle) {
//    final intervalWidth =
//        epochToCanvasX(candles[1].epoch) - epochToCanvasX(candles[0].epoch);
//    final candleWidth = intervalWidth * 0.6;
//
//    final candlePaintings = candles.map((candle) {
//      return CandlePainting(
//        width: candleWidth,
//        xCenter: epochToCanvasX(candle.epoch),
//        yHigh: quoteToCanvasY(candle.high),
//        yLow: quoteToCanvasY(candle.low),
//        yOpen: quoteToCanvasY(candle.open),
//        yClose: quoteToCanvasY(candle.close),
//      );
//    }).toList();
//
//    paintCandles(canvas, candlePaintings, candleStyle);
//  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(ChartPainter oldDelegate) => false;
}
