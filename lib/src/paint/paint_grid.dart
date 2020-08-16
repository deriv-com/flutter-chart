import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:flutter/material.dart';

import '../paint/paint_text.dart';

void paintGrid(
  Canvas canvas,
  Size size, {
  @required List<String> timeLabels,
  @required List<String> quoteLabels,
  @required List<double> xCoords,
  @required List<double> yCoords,
  @required double quoteLabelsAreaWidth,
  @required GridStyle style,
}) {
  assert(timeLabels.length == xCoords.length);
  assert(quoteLabels.length == yCoords.length);

  _paintTimeGridLines(canvas, size, xCoords, style);
  _paintQuoteGridLines(canvas, size, yCoords, quoteLabelsAreaWidth, style);

  _paintQuoteLabels(
    canvas,
    size,
    yCoords: yCoords,
    quoteLabels: quoteLabels,
    quoteLabelsAreaWidth: quoteLabelsAreaWidth,
    style: style,
  );
  _paintTimeLabels(
    canvas,
    size,
    xCoords: xCoords,
    timeLabels: timeLabels,
    style: style,
  );
}

void _paintTimeGridLines(
  Canvas canvas,
  Size size,
  List<double> xCoords,
  GridStyle style,
) {
  xCoords.forEach((x) {
    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height - 20),
      Paint()
        ..color = style.gridLineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = style.gridLineWidth,
    );
  });
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
        ..strokeWidth = style.gridLineWidth,
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
    paintTextFromCenter(
      canvas,
      text: quoteLabel,
      centerX: size.width - quoteLabelsAreaWidth / 2,
      centerY: yCoords[index],
      style: style.labelStyle,
    );
  });
}

void _paintTimeLabels(
  Canvas canvas,
  Size size, {
  @required List<String> timeLabels,
  @required List<double> xCoords,
  @required GridStyle style,
}) {
  timeLabels.asMap().forEach((index, timeLabel) {
    paintTextFromCenter(
      canvas,
      text: timeLabel,
      centerX: xCoords[index],
      centerY: size.height - 10,
      style: style.labelStyle,
    );
  });
}
