import 'package:flutter/material.dart';

import '../../paint/paint_text.dart';

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

void _paintTimeGridLines(Canvas canvas, Size size, List<double> xCoords) {
  xCoords.forEach((x) {
    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height - 20),
      Paint()..color = Colors.white12,
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
