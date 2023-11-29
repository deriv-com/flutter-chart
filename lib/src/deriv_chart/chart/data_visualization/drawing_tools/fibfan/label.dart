import 'package:flutter/material.dart';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/vector.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';

/// A constant for the zero degree vector label
const String zeroDegreeVectorPercentage = '0';

/// A constant for the initial inner vector label
const String initialInnerVectorPercentage = '38.2';

/// A constant for the middle vector label
const String middleInnerVectorPercentage = '50';

/// A constant for the final vector label
const String finalInnerVectorPercentage = '61.8';

/// A constant for the base vector label
const String baseVectorPercentage = '100';

/// A constant for the label horizontal padding
const double labelHorizontalPadding = 25;

/// A constant for the chart horizontal padding
// TODO(NA): Remove this constant and calculate the y axis label width
const double chartPadding = 60;

/// A class for drawing the vector label
class Label {
  /// Initializes the vector label class
  Label({
    required this.startXCoord,
    required this.endXCoord,
  });

  /// Start of the drawing
  final int startXCoord;

  /// End of the drawing
  final int endXCoord;

  /// Returns the x position of the label
  double _getX(
    String label,
    Size size, {
    bool isRightSide = false,
  }) =>
      isRightSide
          ? size.width - chartPadding - labelHorizontalPadding
          : labelHorizontalPadding;

  /// Returns the position of the label on the right side of the chart
  Offset _getRightSideLabelsPosition(String label, Size size, Vector vector) {
    final double x = _getX(label, size, isRightSide: true);

    final double y = (((vector.y1 - vector.y0) / (vector.x1 - vector.x0)) *
            (x - vector.x0)) +
        vector.y0;
    return Offset(x, y);
  }

  /// Returns the position of the label on the left side of the chart
  Offset _getLeftSideLabelsPosition(String label, Vector vector) {
    final double x = _getX(label, Size.zero);

    final double y = (((vector.y1 - vector.y0) / (vector.x1 - vector.x0)) *
            (x - vector.x0)) +
        vector.y0;
    return Offset(5, y);
  }

  /// Returns the text painter for adding labels
  TextPainter getTextPainter(String label, Offset textOffset, Color color) {
    final TextStyle textStyle = TextStyle(
      color: color,
      fontWeight: FontWeight.bold,
      fontSize: 13,
    );

    final TextSpan textSpan = TextSpan(
      text: '$label%',
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
    Size size,
    LineStyle lineStyle,
    String label,
    Vector endVector,
  ) {
    final Offset labelOffset = (startXCoord > endXCoord && startXCoord > 10)
        ? _getLeftSideLabelsPosition(label, endVector)
        : (startXCoord < endXCoord && startXCoord < size.width - chartPadding)
            ? _getRightSideLabelsPosition(label, size, endVector)
            : Offset.zero;
    if (labelOffset != Offset.zero) {
      getTextPainter(label, labelOffset, lineStyle.color)
        ..layout()
        ..paint(canvas, labelOffset);
    }
  }
}
