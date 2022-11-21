import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';

/// Paints a horizontal dashed-line for the given parameters.
void paintHorizontalShade(Canvas canvas, double shadeStartX, double shadeEndX,
    double lineY, ShadeType shadeType, Color shadeColor) {
  final Rect rect;

  if (shadeType == ShadeType.above) {
    rect = Rect.fromLTRB(shadeStartX, lineY - 180, shadeEndX, lineY);
  } else {
    rect = Rect.fromLTRB(shadeStartX, lineY + 180, shadeEndX, lineY);
  }

  const LinearGradient lg = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[
        Color.fromARGB(20, 255, 255, 255),
        Color.fromARGB(80, 57, 177, 157)
      ]);

  final Paint paint = Paint()..shader = lg.createShader(rect);

  canvas.drawRect(rect, paint);
}
