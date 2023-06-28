import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/drawing_paint_style.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:intl/intl.dart';

/// A class that hold drawing data.
class DrawingLabel {
  /// Initializes
  DrawingLabel({
    required this.canvas,
    required this.size,
    required this.coord,
    this.epochFromX,
    this.quoteFromY,
  });

  /// Canvas.
  final Canvas canvas;

  /// Total size of the string.
  final Size size;

  /// function to convert x coord to epoch.
  int Function(double)? epochFromX;

  /// function to convert y coord to quote.
  final double Function(double)? quoteFromY;

  /// If the drawing is selected by the user.
  final double coord;

  /// Name of the of label
  String _labelString = '';

  /// Outline Rectangle of the label
  Rect labelRect = Rect.zero;

  /// Offset from where the text starts
  Offset _textOffset = Offset.zero;

  /// Width of the rectangle
  final double _width = 50;

  /// Height of the rectangle
  final double _height = 20;

  /// Function that set the outlined rectangle , text offset
  ///  and label for vertical drawing
  void setVerticalLabel() {
    labelRect = Rect.fromCenter(
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
      coord - 18,
      size.height - 13,
    );
  }

  /// Function that set the outlined rectangle , text offset
  ///  and label for horizontal drawing
  void setHorizontalLabel() {
    labelRect = Rect.fromCenter(
      center: Offset(size.width - 25, coord),
      width: _width,
      height: _height,
    );

    _labelString = quoteFromY!(coord).toStringAsFixed(3);

    _textOffset = Offset(
      size.width - 44,
      coord - 5,
    );
  }

  /// Updates drawing list.
  void drawLabel() {
    final DrawingPaintStyle paint = DrawingPaintStyle();

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: _labelString, // Concatenate the timeLabel here
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: size.width);

    canvas.drawRect(labelRect, paint.labelPaintStyle());
    textPainter.paint(canvas, _textOffset);
  }
}
