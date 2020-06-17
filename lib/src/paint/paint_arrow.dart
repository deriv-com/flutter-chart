import 'package:flutter/material.dart';

void paintArrow(
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
  _paintArrowHead(
    canvas,
    size,
    centerY: centerY,
    quoteLabel: quoteLabel,
    quoteLabelsAreaWidth: quoteLabelsAreaWidth,
  );
}

void _paintArrowHead(
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

  TextSpan span = TextSpan(
    style: TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
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
    Offset(size.width - quoteLabelsAreaWidth, centerY - 6),
  );
}
