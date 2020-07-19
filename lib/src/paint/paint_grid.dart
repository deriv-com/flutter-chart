import 'package:flutter/material.dart';

void paintGrid(
  Canvas canvas,
  Size size, {
  @required List<String> timeLabels,
  @required List<String> quoteLabels,
  @required List<double> xCoords,
  @required List<double> yCoords,
  @required double quoteLabelsAreaWidth,
}) {
  assert(timeLabels.length == xCoords.length);
  assert(quoteLabels.length == yCoords.length);

  _paintTimeGridLines(canvas, size, xCoords);
  _paintQuoteGridLines(canvas, size, yCoords, quoteLabelsAreaWidth);

  _paintQuoteLabels(
    canvas,
    size,
    yCoords: yCoords,
    quoteLabels: quoteLabels,
    quoteLabelsAreaWidth: quoteLabelsAreaWidth,
  );
  _paintTimeLabels(
    canvas,
    size,
    xCoords: xCoords,
    timeLabels: timeLabels,
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
    final y = yCoords[index];
    final fontSize = 12.0;

    TextSpan span = TextSpan(
      style: TextStyle(color: Colors.white30, fontSize: fontSize),
      text: quoteLabel,
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout(minWidth: quoteLabelsAreaWidth, maxWidth: quoteLabelsAreaWidth);
    tp.paint(
      canvas,
      Offset(size.width - quoteLabelsAreaWidth, y - fontSize / 2),
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
    final x = xCoords[index];

    TextSpan span = TextSpan(
      style: TextStyle(color: Colors.white30, fontSize: 12),
      text: timeLabel,
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(x - tp.width / 2, size.height - tp.height - 4),
    );
  });
}
