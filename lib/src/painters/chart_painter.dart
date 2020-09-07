import 'package:deriv_chart/src/logic/chart_series/base_series.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:flutter/material.dart';

class ChartPainter extends CustomPainter {
  ChartPainter({
    this.pipSize,
    this.mainSeries,
    this.animationInfo,
    this.epochToCanvasX,
    this.quoteToCanvasY,
  });

  final int pipSize;

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

  @override
  bool shouldRepaint(ChartPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(ChartPainter oldDelegate) => false;
}
