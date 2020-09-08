import 'package:deriv_chart/src/theme/painting_styles/current_tick_style.dart';
import 'package:flutter/material.dart';

import '../paint/paint_text.dart';

void paintCurrentTickLabelBackground(
  Canvas canvas,
  Size size, {
  @required double centerY,
  @required String quoteLabel,
  @required double quoteLabelsAreaWidth,
  @required double currentTickX,
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
}

// TODO(Ramin): Move to a general file where general painting functions are there
/// Paints a horizontal dashed-line for the given parameters.
void paintHorizontalDashedLine(
  Canvas canvas,
  double lineStartX,
  double lineEndX,
  double lineY,
  Color lineColor,
  double lineThickness, {
  double dashWidth = 4,
  double dashSpace = 4,
}) {
  double startX = lineStartX;

  final Paint paint = Paint()
    ..color = lineColor
    ..strokeWidth = lineThickness;

  while (startX <= lineEndX) {
    canvas.drawLine(
      Offset(startX, lineY),
      Offset(startX + dashWidth, lineY),
      paint,
    );
    startX += dashSpace + dashWidth;
  }
}
