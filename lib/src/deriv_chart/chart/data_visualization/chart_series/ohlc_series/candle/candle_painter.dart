import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';

import '../../data_painter.dart';
import '../ohlc_painting.dart';
import '../ohlc_painter.dart';

/// A [DataPainter] for painting CandleStick data.
class CandlePainter extends OhlcPainter {
  /// Initializes
  CandlePainter(DataSeries<Candle> series) : super(series);

  late Paint _linePaint;
  late Paint _positiveCandlePaint;
  late Paint _negativeCandlePaint;

  @override
  void onPaintCandle(
    Canvas canvas,
    Size size,
    OhlcPainting currentPainting,
    OhlcPainting prevPainting,
  ) {
    final CandleStyle style = series.style as CandleStyle? ?? theme.candleStyle;

    _linePaint = Paint()
      ..color = style.neutralColor
      ..strokeWidth = 1.2;

    _positiveCandlePaint = Paint()..color = style.positiveColor;
    _negativeCandlePaint = Paint()..color = style.negativeColor;

    yAxisClipping(canvas, size, () {
      canvas.drawLine(
        Offset(currentPainting.xCenter, currentPainting.yHigh),
        Offset(currentPainting.xCenter, currentPainting.yLow),
        _linePaint,
      );

      if (currentPainting.yOpen == currentPainting.yClose) {
        canvas.drawLine(
          Offset(currentPainting.xCenter - currentPainting.width / 2,
              currentPainting.yOpen),
          Offset(currentPainting.xCenter + currentPainting.width / 2,
              currentPainting.yOpen),
          _linePaint,
        );
      } else if (currentPainting.yOpen > currentPainting.yClose) {
        canvas.drawRect(
          Rect.fromLTRB(
            currentPainting.xCenter - currentPainting.width / 2,
            currentPainting.yClose,
            currentPainting.xCenter + currentPainting.width / 2,
            currentPainting.yOpen,
          ),
          _positiveCandlePaint,
        );
      } else {
        canvas.drawRect(
          Rect.fromLTRB(
            currentPainting.xCenter - currentPainting.width / 2,
            currentPainting.yOpen,
            currentPainting.xCenter + currentPainting.width / 2,
            currentPainting.yClose,
          ),
          _negativeCandlePaint,
        );
      }
    });
  }
}
