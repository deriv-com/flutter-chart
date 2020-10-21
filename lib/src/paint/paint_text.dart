import 'package:flutter/material.dart';

/// Paints text on the canvas.
void paintText(
  Canvas canvas, {
  @required String text,
  @required Offset anchor,
  Alignment anchorAlignment = Alignment.center,
  TextStyle style,
}) {
  final TextSpan span = TextSpan(
    text: text,
    style: style,
  );
  final TextPainter tp = TextPainter(
    text: span,
    textDirection: TextDirection.ltr,
  );
  tp
    ..layout()
    ..paint(
      canvas,
      Offset(
        anchor.dx - tp.width / 2 * (anchorAlignment.x + 1),
        anchor.dy - tp.height / 2 * (anchorAlignment.y + 1),
      ),
    );
}
