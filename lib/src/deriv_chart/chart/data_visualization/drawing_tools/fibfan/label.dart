import 'package:flutter/material.dart';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/vector.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';

/// A class for drawing the vector label
class Label {
  /// Initializes the vector label class
  Label({
    required this.startEpoch,
    required this.endEpoch,
  });

  /// Start epoch of the drawing
  int startEpoch;

  /// End epoch of the drawing
  int endEpoch;

  /// Returns the x position of the label
  double _getX(
    String label, {
    bool isRightSide = false,
  }) {
    switch (label) {
      case '0%':
        return isRightSide ? 345 : 25;
      case '38.2%':
      case '61.8%':
        return isRightSide ? 325 : 40;
      case '50%':
        return isRightSide ? 335 : 30;
      default:
        return isRightSide ? 330 : 10;
    }
  }

  /// Returns the position of the label on the right side of the chart
  Offset _getRightSideLabelsPosition(String label, Vector vector) {
    final double x = _getX(label, isRightSide: true);

    final double y = (((vector.y1 - vector.y0) / (vector.x1 - vector.x0)) *
            (x - vector.x0)) +
        vector.y0;
    return Offset(x, y);
  }

  /// Returns the position of the label on the left side of the chart
  Offset _getLeftSideLabelsPosition(String label, Vector vector) {
    final double x = _getX(label);

    final double y = (((vector.y1 - vector.y0) / (vector.x1 - vector.x0)) *
            (x - vector.x0)) +
        vector.y0;
    return Offset(5, y);
  }

  /// Returns the text painter for adding labels
  TextPainter getTextPainter(String label, Offset textOffset, Color color) {
    final TextStyle textStyle = TextStyle(
      color: color,
      fontSize: 13,
    );

    final TextSpan textSpan = TextSpan(
      text: label,
      style: textStyle,
    );

    return TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
  }

  /// Draw the vector label
  void drawLabel(
    Canvas canvas,
    LineStyle lineStyle,
    String label,
    Vector endVector,
  ) {
    final Offset labelOffset = startEpoch > endEpoch
        ? _getLeftSideLabelsPosition(label, endVector)
        : _getRightSideLabelsPosition(label, endVector);
    getTextPainter(label, labelOffset, lineStyle.color)
      ..layout()
      ..paint(canvas, labelOffset);
  }
}
