import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import '../drawing.dart';

/// Vertical drawing tool. A vertical is a vertical line defined by one point
/// that is infinite in both directions.
class VerticalDrawing extends Drawing {
  /// Initializes
  VerticalDrawing({
    required this.drawingPart,
    this.startEpoch = 0,
    this.startYCoord = 0,
    this.endEpoch = 0,
    this.endYCoord = 0,
  });

  /// Part of a drawing: 'marker' or 'line'
  final String drawingPart;

  /// Starting epoch.
  final int? startEpoch;

  /// Starting Y coordinates.
  final double? startYCoord;

  /// Ending epoch.
  final int? endEpoch;

  /// Ending Y coordinates.
  final double? endYCoord;

  /// Paint
  @override
  void onPaint(Canvas canvas, Size size, ChartTheme theme,
      double Function(int x) epochToX, DrawingToolConfig config) {
    final LineStyle lineStyle = config.toJson()['lineStyle'];
    final String pattern = config.toJson()['pattern'];

    if (drawingPart == 'vertical') {
      if (startEpoch != null &&
          endEpoch != null &&
          startYCoord != null &&
          endYCoord != null) {
        final double startXCoord = epochToX(startEpoch!);

        final double startY = startYCoord! - 1000,
            endingY = startYCoord! + 1000,
            startX = startXCoord;

        if (pattern == 'solid') {
          canvas.drawLine(
              Offset(startX, startY),
              Offset(startX, endingY),
              Paint()
                ..color = lineStyle.color
                ..strokeWidth = lineStyle.thickness);
        }
      }
    }
  }
}
