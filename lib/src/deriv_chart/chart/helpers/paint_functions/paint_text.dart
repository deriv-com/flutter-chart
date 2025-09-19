import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Paints text on the canvas.
void paintText(
  Canvas canvas, {
  required String text,
  required Offset anchor,
  required TextStyle style,
  Alignment anchorAlignment = Alignment.center,
}) {
  final TextPainter painter = makeTextPainter(text, style);
  paintWithTextPainter(
    canvas,
    painter: painter,
    anchor: anchor,
    anchorAlignment: anchorAlignment,
  );
}

/// Constructs a text painter and performs layout.
///
/// Use this in combination with `paintWithTextPainter`,
/// if you need to know text size on the canvas.
///
/// e.g.
/// ```
/// final tp = makeTextPainter('Hello', style);
/// final w = tp.width; // text width
/// final h = tp.height; // text height
///
/// paintWithTextPainter(
///   canvas,
///   painter: tp,
///   anchor: Offset(0, 0),
///   anchorAlignment: Alignment.centerRight,
/// );
/// ```
TextPainter makeTextPainter(String text, TextStyle style) {
  final TextSpan span = TextSpan(
    text: text,
    style: style,
  );
  return TextPainter(
    text: span,
    textDirection: TextDirection.ltr,
  )..layout();
}

/// Constructs a text painter that fits within the given bounds by
/// scaling the font size down if necessary (never scales up).
TextPainter makeFittedTextPainter(
  String text,
  TextStyle style, {
  required double maxWidth,
  required double maxHeight,
}) {
  final TextPainter painter = makeTextPainter(text, style);

  // Early return if already fits
  if (painter.width <= maxWidth && painter.height <= maxHeight) {
    return painter;
  }

  final double currentFontSize = style.fontSize ?? 12;
  final double widthScale = maxWidth / painter.width;
  final double heightScale = maxHeight / painter.height;
  final double scale = math.min(widthScale, heightScale);

  final TextStyle fittedStyle = style.copyWith(
    fontSize: currentFontSize * scale,
  );

  return makeTextPainter(text, fittedStyle);
}

/// Paints on the canvas with the given text painter.
void paintWithTextPainter(
  Canvas canvas, {
  required TextPainter painter,
  required Offset anchor,
  Alignment anchorAlignment = Alignment.center,
}) {
  painter.paint(
    canvas,
    Offset(
      anchor.dx - painter.width / 2 * (anchorAlignment.x + 1),
      anchor.dy - painter.height / 2 * (anchorAlignment.y + 1),
    ),
  );
}
