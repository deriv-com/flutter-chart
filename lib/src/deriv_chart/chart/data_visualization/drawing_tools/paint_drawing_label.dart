import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

/// Function is responsible for creating the label for vertical and
///  horizontal drawing
void paintDrawingLabel(
  Canvas canvas,
  Size size,
  double coord,
  String drawingType,
  ChartTheme theme,
  ChartConfig config, {
  int Function(double x)? epochFromX,
  double Function(double)? quoteFromY,
  Color color = Colors.white,
}) {
  /// Name of the of label
  String _labelString = '';

  final HorizontalBarrierStyle horizontalBarrierStyle =
      theme.horizontalBarrierStyle;

  if (drawingType == 'horizontal') {
    _labelString = quoteFromY!(coord).toStringAsFixed(config.pipSize);
  } else {
    final DateTime _dateTime =
        DateTime.fromMillisecondsSinceEpoch(epochFromX!(coord), isUtc: true);

    _labelString = DateFormat('MM-dd HH:mm:ss').format(_dateTime);
  }

  const double padding = 6;
  final TextPainter textPainter = TextPainter(
    text: TextSpan(
      text: _labelString,
      style: TextStyle(
        color: calculateTextColor(color),
        fontSize: horizontalBarrierStyle.textStyle.fontSize,
        height: horizontalBarrierStyle.textStyle.height,
        fontFeatures: horizontalBarrierStyle.textStyle.fontFeatures,
        fontWeight: horizontalBarrierStyle.textStyle.fontWeight,
      ),
    ),
    textDirection: ui.TextDirection.ltr,
    maxLines: 1,
  )..layout(maxWidth: size.width);

  final double rectWidth = textPainter.width + 2 * padding;
  const double rectHeight = 24;

  RRect rect = RRect.zero;

  if (drawingType == 'horizontal') {
    rect = RRect.fromLTRBR(
      size.width - rectWidth - 1,
      coord - (rectHeight / 2),
      size.width - 4,
      coord + (rectHeight / 2),
      const Radius.circular(4),
    );
  } else {
    rect = RRect.fromLTRBR(
      coord - (rectWidth / 2),
      size.height - rectHeight,
      coord + (rectWidth / 2),
      size.height,
      const Radius.circular(4),
    );
  }

  canvas.drawRRect(
    rect,
    Paint()
      ..color = color
      ..style = PaintingStyle.fill,
  );
  if (drawingType == 'horizontal') {
    textPainter.paint(
        canvas,
        Offset(size.width - rectWidth + padding - 2,
            coord - textPainter.height / 2));
  } else {
    textPainter.paint(
        canvas,
        Offset(coord - textPainter.width / 2,
            size.height - textPainter.height - padding + 1));
  }
}
