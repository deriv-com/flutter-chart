import 'package:deriv_chart/src/paint/paint_text.dart';
import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:flutter/material.dart';

void paintXGrid(
  Canvas canvas,
  Size size, {
  @required List<String> timeLabels,
  @required List<double> xCoords,
  @required GridStyle style,
}) {
  assert(timeLabels.length == xCoords.length);

  _paintTimeGridLines(canvas, size, xCoords, style);
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
        ..strokeWidth = style.lineThickness,
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
