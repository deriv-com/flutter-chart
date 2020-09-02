import 'package:deriv_chart/src/theme/painting_styles/candle_style.dart';
import 'package:flutter/material.dart';

import '../models/candle_painting.dart';

void paintCandles(
  Canvas canvas,
  List<CandlePainting> candlePaintings,
  CandleStyle candleStyle,
) {
  candlePaintings.forEach((candlePainting) {
    _paintCandle(canvas, candlePainting, candleStyle);
  });
}

void _paintCandle(Canvas canvas, CandlePainting cp, CandleStyle candleStyle) {
  final linePaint = Paint()
    ..color = candleStyle.lineColor
    ..strokeWidth = 1.2;

  canvas.drawLine(
    Offset(cp.xCenter, cp.yHigh),
    Offset(cp.xCenter, cp.yLow),
    linePaint,
  );

  if (cp.yOpen == cp.yClose) {
    canvas.drawLine(
      Offset(cp.xCenter - cp.width / 2, cp.yOpen),
      Offset(cp.xCenter + cp.width / 2, cp.yOpen),
      linePaint,
    );
  } else if (cp.yOpen > cp.yClose) {
    canvas.drawRect(
      Rect.fromLTRB(
        cp.xCenter - cp.width / 2,
        cp.yClose,
        cp.xCenter + cp.width / 2,
        cp.yOpen,
      ),
      Paint()..color = candleStyle.positiveColor,
    );
  } else {
    canvas.drawRect(
      Rect.fromLTRB(
        cp.xCenter - cp.width / 2,
        cp.yOpen,
        cp.xCenter + cp.width / 2,
        cp.yClose,
      ),
      Paint()..color = candleStyle.negativeColor,
    );
  }
}
