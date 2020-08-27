import 'package:flutter/material.dart';

import 'paint_text.dart';

void paintYGrid(
  Canvas canvas,
  Size size, {
  @required List<String> quoteLabels,
  @required List<double> yCoords,
  @required double quoteLabelsAreaWidth,
}) {
  assert(quoteLabels.length == yCoords.length);

  _paintQuoteGridLines(canvas, size, yCoords, quoteLabelsAreaWidth);
  _paintQuoteLabels(
    canvas,
    size,
    yCoords: yCoords,
    quoteLabels: quoteLabels,
    quoteLabelsAreaWidth: quoteLabelsAreaWidth,
  );
}

void _paintQuoteGridLines(
  Canvas canvas,
  Size size,
  List<double> yCoords,
  double quoteLabelsAreaWidth,
) {
  yCoords.forEach((y) {
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width - quoteLabelsAreaWidth, y),
      Paint()..color = Colors.white12,
    );
  });
}

void _paintQuoteLabels(
  Canvas canvas,
  Size size, {
  @required List<double> yCoords,
  @required List<String> quoteLabels,
  @required double quoteLabelsAreaWidth,
}) {
  quoteLabels.asMap().forEach((index, quoteLabel) {
    paintTextFromCenter(
      canvas,
      text: quoteLabel,
      centerX: size.width - quoteLabelsAreaWidth / 2,
      centerY: yCoords[index],
      style: TextStyle(
        color: Colors.white30, // TODO(Ramin): Use theme's color when it's ready
        fontSize: 12,
        height: 1,
      ),
    );
  });
}
