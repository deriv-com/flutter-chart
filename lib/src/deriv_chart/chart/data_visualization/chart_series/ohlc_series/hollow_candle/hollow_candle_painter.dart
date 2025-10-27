import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/theme/painting_styles/candle_style.dart';
import 'package:flutter/material.dart';

import '../../data_painter.dart';
import '../../data_series.dart';
import '../ohlc_painting.dart';
import '../ohlc_painter.dart';

/// A [DataPainter] for painting Hollow CandleStick data.
class HollowCandlePainter extends OhlcPainter {
  /// Initializes
  HollowCandlePainter(DataSeries<Candle> series) : super(series);

  late Color _candleBullishBodyColor;
  late Color _candleBearishBodyColor;
  late Color _candleBullishWickColor;
  late Color _candleBearishWickColor;

  @override
  void onPaintCandle(
    Canvas canvas,
    OhlcPainting currentPainting,
    OhlcPainting prevPainting,
  ) {
    final CandleStyle style = series.style as CandleStyle? ?? theme.candleStyle;

    _candleBullishBodyColor = style.candleBullishBodyColor;
    _candleBearishBodyColor = style.candleBearishBodyColor;
    _candleBullishWickColor = style.candleBullishWickColor;
    _candleBearishWickColor = style.candleBearishWickColor;

    // Check if the current candle is bullish or bearish.
    final bool isBullishCandle = currentPainting.yOpen > currentPainting.yClose;

    final Color _candleColor =
        isBullishCandle ? _candleBullishBodyColor : _candleBearishBodyColor;

    final Color candleWickColor =
        isBullishCandle ? _candleBullishWickColor : _candleBearishWickColor;

    _drawWick(canvas, candleWickColor, currentPainting);

    if (currentPainting.yOpen == currentPainting.yClose) {
      _drawLine(canvas, _candleColor, currentPainting);
    } else if (currentPainting.yOpen < currentPainting.yClose) {
      _drawFilledRect(canvas, _candleColor, currentPainting);
    } else {
      _drawHollowRect(canvas, _candleColor, currentPainting);
    }
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

  @override
  List<CustomPainterSemantics> buildSemantics(
      {required Size size,
      required EpochToX epochToX,
      required QuoteToY quoteToY}) {
    return <CustomPainterSemantics>[];
  }
}
