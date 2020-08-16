import 'package:deriv_chart/src/theme/painting_styles/current_tick_style.dart';
import 'package:flutter/material.dart';

import '../paint/paint_text.dart';

void paintCurrentTickLabel(
  Canvas canvas,
  Size size, {
  @required double centerY,
  @required String quoteLabel,
  @required double quoteLabelsAreaWidth,
  @required CurrentTickStyle style,
}) {
  canvas.drawLine(
    Offset(0, centerY),
    Offset(size.width, centerY),
    Paint()
      ..color = style.color
      ..strokeWidth = style.lineThickness,
  );
  _paintLabel(
    canvas,
    size,
    centerY: centerY,
    quoteLabel: quoteLabel,
    quoteLabelsAreaWidth: quoteLabelsAreaWidth,
    style: style,
  );
}

void _paintLabel(
  Canvas canvas,
  Size size, {
  @required double centerY,
  @required String quoteLabel,
  @required double quoteLabelsAreaWidth,
  @required CurrentTickStyle style,
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
      ..color = style.color
      ..style = PaintingStyle.fill,
  );

  paintTextFromCenter(
    canvas,
    text: quoteLabel,
    centerX: size.width - quoteLabelsAreaWidth / 2,
    centerY: centerY,
    style: style.labelStyle,
  );
}
