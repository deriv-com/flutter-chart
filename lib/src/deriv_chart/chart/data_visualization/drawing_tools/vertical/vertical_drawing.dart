import 'package:deriv_chart/src/add_ons/drawing_tools_ui/vertical/vertical_drawing_tool_config.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import '../drawing.dart';

/// Vertical drawing tool. A vertical is a vertical line defined by one point
/// that is infinite in both directions.
class VerticalDrawing extends Drawing<VerticalDrawingToolConfig> {
  /// Initializes
  VerticalDrawing({
    required this.drawingPart,
    this.epoch = 0,
    this.yCoord = 0,
  });

  /// Part of a drawing: 'vertical'
  final String drawingPart;

  /// Starting epoch.
  final int epoch;

  /// Starting Y coordinates.
  final double yCoord;

  /// Paint
  @override
  void onPaint(
      Canvas canvas,
      Size size,
      ChartTheme theme,
      double Function(int x) epochToX,
      double Function(double y) quoteToY,
      VerticalDrawingToolConfig config) {
    final LineStyle lineStyle = config.lineStyle;
    final String pattern = config.pattern;
    final double startQuoteToY = quoteToY(yCoord);

    if (drawingPart == 'vertical') {
      final double xCoord = epochToX(epoch);

      final double startY = startQuoteToY - 1000,
          endingY = startQuoteToY + 1000;

      if (pattern == 'solid') {
        canvas.drawLine(
            Offset(xCoord, startY),
            Offset(xCoord, endingY),
            Paint()
              ..color = lineStyle.color
              ..strokeWidth = lineStyle.thickness);
      }
    }
  }
}
