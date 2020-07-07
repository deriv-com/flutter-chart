import 'package:flutter/material.dart';

void paintText(
  Canvas canvas, {
  @required String text,
  @required double centerX,
  @required double centerY,
  TextStyle style,
}) {
  TextSpan span = TextSpan(
    text: text,
    style: style,
  );
  TextPainter tp = TextPainter(
    text: span,
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );
  tp.layout();
  tp.paint(
    canvas,
    Offset(
      centerX - tp.width / 2,
      centerY - tp.height / 2,
    ),
  );
}
