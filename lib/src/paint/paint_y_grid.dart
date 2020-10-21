import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:flutter/material.dart';

import 'paint_text.dart';

void paintYGrid(
  Canvas canvas,
  Size size, {
  @required List<String> quoteLabels,
  @required List<double> yCoords,
  @required double quoteLabelsAreaWidth,
  @required GridStyle style,
}) {
  assert(quoteLabels.length == yCoords.length);

  _paintQuoteGridLines(canvas, size, yCoords, quoteLabelsAreaWidth, style);

  _paintQuoteLabels(
    canvas,
    size,
    yCoords: yCoords,
    quoteLabels: quoteLabels,
    quoteLabelsAreaWidth: quoteLabelsAreaWidth,
    style: style,
  );
}

void _paintQuoteGridLines(
  Canvas canvas,
  Size size,
  List<double> yCoords,
  double quoteLabelsAreaWidth,
  GridStyle style,
) {
  yCoords.forEach((y) {
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width - quoteLabelsAreaWidth, y),
      Paint()
        ..color = style.gridLineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = style.lineThickness,
    );
  });
}

void _paintQuoteLabels(
  Canvas canvas,
  Size size, {
  @required List<double> yCoords,
  @required List<String> quoteLabels,
  @required double quoteLabelsAreaWidth,
  @required GridStyle style,
}) {
  quoteLabels.asMap().forEach((index, quoteLabel) {
    paintText(
      canvas,
      text: quoteLabel,
      anchor: Offset(
        size.width - quoteLabelsAreaWidth / 2,
        yCoords[index],
      ),
      style: style.labelStyle,
    );
  });
}
