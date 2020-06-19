import 'package:flutter/material.dart';

import '../models/candle_painting.dart';

void paintCandles(Canvas canvas, List<CandlePainting> candlePaintings) {
  candlePaintings.forEach((candlePaiting) {
    _paintCandle(canvas, candlePaiting);
  });
}

void _paintCandle(Canvas canvas, CandlePainting cp) {
  final linePaint = Paint()
    ..color = Color(0xFF6E6E6E)
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
      Paint()..color = Color(0xFF00A79E),
    );
  } else {
    canvas.drawRect(
      Rect.fromLTRB(
        cp.xCenter - cp.width / 2,
        cp.yOpen,
        cp.xCenter + cp.width / 2,
        cp.yClose,
      ),
      Paint()..color = Color(0xFFCC2E3D),
    );
  }
}
