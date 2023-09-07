import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
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
}) {
  /// Outline Rectangle of the label
  Rect _labelRect = Rect.zero;

  /// Offset from where the text starts
  Offset _textOffset = Offset.zero;

  /// Name of the of label
  String _labelString = '';

  /// Width of the rectangle
  const double _width = 46;

  /// Height of the rectangle
  const double _height = 24;

  final HorizontalBarrierStyle horizontalBarrierStyle =
      theme.horizontalBarrierStyle;

  if (drawingType == 'horizontal') {
    _labelRect = Rect.fromCenter(
      center: Offset(size.width - 26, coord),
      width: _width,
      height: _height,
    );

    _labelString = quoteFromY!(coord).toStringAsFixed(config.pipSize);

    _textOffset = Offset(
      size.width - 44,
      coord - 5,
    );
  } else {
    _labelRect = Rect.fromCenter(
      center: Offset(
        coord,
        size.height - 6,
      ),
      width: _width,
      height: _height,
    );

    final DateTime _dateTime =
        DateTime.fromMillisecondsSinceEpoch(epochFromX!(coord), isUtc: true);

    _labelString = DateFormat('HH:mm:ss').format(_dateTime);

    _textOffset = Offset(
      coord - 19,
      size.height - 13,
    );
  }

  final TextPainter textPainter = TextPainter(
    text: TextSpan(
      text: _labelString,
      style: TextStyle(
        color: horizontalBarrierStyle.titleBackgroundColor,
        fontSize: 10,
      ),
    ),
    textDirection: ui.TextDirection.ltr,
  )..layout(maxWidth: size.width);

  final RRect roundedRect =
      RRect.fromRectAndRadius(_labelRect, const Radius.circular(4));

  canvas.drawRRect(
    roundedRect,
    Paint()..color = horizontalBarrierStyle.color,
  );
  textPainter.paint(canvas, _textOffset);
}
