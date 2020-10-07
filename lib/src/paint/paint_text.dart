import 'package:flutter/material.dart';

void paintTextFromCenter(
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

/// Paints a screen with the padding specified for its right side
void paintTextFromRight(
  Canvas canvas, {
  @required String text,
  @required double x,
  @required double y,
  double rightPadding = 10,
  TextStyle style,
}) {
  TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );
  textPainter
    ..layout()
    ..paint(
        canvas,
        Offset(
          x - textPainter.width - rightPadding,
          y - textPainter.height / 2,
        ));
}
