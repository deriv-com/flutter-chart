import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/theme/painting_styles/candle_style.dart';
import 'package:flutter/material.dart';

import '../../data_painter.dart';
import '../../data_series.dart';
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
    OhlcPainting currentPainting,
    OhlcPainting prevPainting,
  ) {
    final CandleStyle style = series.style as CandleStyle? ?? theme.candleStyle;

    _linePaint = Paint()
      ..color = style.neutralColor
      ..strokeWidth = 1.2;

    _positiveCandlePaint = Paint()..color = style.positiveColor;
    _negativeCandlePaint = Paint()..color = style.negativeColor;

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
  }
}
