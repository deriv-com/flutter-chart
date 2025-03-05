import 'package:flutter/material.dart';

/// Paints start time marker
void paintStartMarker(
    Canvas canvas, Offset offset, Color color, double iconSize) {
  const IconData icon = Icons.location_on;

  TextPainter(textDirection: TextDirection.ltr)
    ..text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: iconSize,
        fontFamily: icon.fontFamily,
        color: color,
      ),
    )
    ..layout()
    ..paint(
      canvas,
      offset,
    );
}
