import 'package:flutter/material.dart';

import '../paint/paint_text.dart';

void paintXGrid(
  Canvas canvas,
  Size size, {
  @required List<String> timeLabels,
  @required List<double> xCoords,
}) {
  assert(timeLabels.length == xCoords.length);

  _paintTimeGridLines(canvas, size, xCoords);
  _paintTimeLabels(
    canvas,
    size,
    xCoords: xCoords,
    timeLabels: timeLabels,
  );
}

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

void _paintTimeGridLines(Canvas canvas, Size size, List<double> xCoords) {
  xCoords.forEach((x) {
    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height - 20),
      Paint()..color = Colors.white12,
    );
  });
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

void _paintTimeLabels(
  Canvas canvas,
  Size size, {
  @required List<String> timeLabels,
  @required List<double> xCoords,
}) {
  timeLabels.asMap().forEach((index, timeLabel) {
    paintTextFromCenter(
      canvas,
      text: timeLabel,
      centerX: xCoords[index],
      centerY: size.height - 10,
      style: TextStyle(
        color: Colors.white30,
        fontSize: 12,
        height: 1,
      ),
    );
  });
}
