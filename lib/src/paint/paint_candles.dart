import 'package:flutter/material.dart';

import '../models/candle_painting.dart';

void paintCandles(
    Canvas canvas, Size size, List<CandlePainting> candlePaintings) {
  candlePaintings.forEach((candlePaiting) {
    _paintCandle(canvas, size, candlePaiting);
  });
}

void _paintCandle(Canvas canvas, Size size, CandlePainting cp) {
  canvas.drawLine(
    Offset(cp.xCenter, cp.yHigh),
    Offset(cp.xCenter, cp.yLow),
    Paint()..color = Colors.white60,
  );

  if (cp.yOpen > cp.yClose) {
    canvas.drawRect(
      Rect.fromLTRB(
        cp.xCenter - cp.width / 2,
        cp.yClose,
        cp.xCenter + cp.width / 2,
        cp.yOpen,
      ),
      Paint()..color = Colors.green,
    );
  } else {
    canvas.drawRect(
      Rect.fromLTRB(
        cp.xCenter - cp.width / 2,
        cp.yOpen,
        cp.xCenter + cp.width / 2,
        cp.yClose,
      ),
      Paint()..color = Colors.red,
    );
  }
}
