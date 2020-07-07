import 'package:flutter/material.dart';

import '../paint/paint_text.dart';

void paintCurrentTickLabel(
  Canvas canvas,
  Size size, {
  @required double centerY,
  @required String quoteLabel,
  @required double quoteLabelsAreaWidth,
}) {
  canvas.drawLine(
    Offset(0, centerY),
    Offset(size.width, centerY),
    Paint()
      ..color = Colors.white24
      ..strokeWidth = 1,
  );
  _paintLabel(
    canvas,
    size,
    centerY: centerY,
    quoteLabel: quoteLabel,
    quoteLabelsAreaWidth: quoteLabelsAreaWidth,
  );
}

void _paintLabel(
  Canvas canvas,
  Size size, {
  @required double centerY,
  @required String quoteLabel,
  @required double quoteLabelsAreaWidth,
}) {
  final triangleWidth = 8;
  final height = 24;

  final path = Path();
  path.moveTo(size.width - quoteLabelsAreaWidth - triangleWidth, centerY);
  path.lineTo(size.width - quoteLabelsAreaWidth, centerY - height / 2);
  path.lineTo(size.width, centerY - height / 2);
  path.lineTo(size.width, centerY + height / 2);
  path.lineTo(size.width - quoteLabelsAreaWidth, centerY + height / 2);
  path.lineTo(size.width - quoteLabelsAreaWidth - triangleWidth, centerY);
  canvas.drawPath(
    path,
    Paint()
      ..color = Color(0xFFFF444F)
      ..style = PaintingStyle.fill,
  );

  paintText(
    canvas,
    text: quoteLabel,
    centerX: size.width - quoteLabelsAreaWidth / 2,
    centerY: centerY,
    style: TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      height: 1,
    ),
  );
}
