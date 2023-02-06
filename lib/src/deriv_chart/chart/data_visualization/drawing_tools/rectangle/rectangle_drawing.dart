import 'dart:math';

import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import '../drawing.dart';

/// Rectangle drawing tool.
class RectangleDrawing extends Drawing {
  /// Initializes
  RectangleDrawing({
    required this.drawingPart,
    this.startEpoch = 0,
    this.startYCoord = 0,
    this.endEpoch = 0,
    this.endYCoord = 0,
  });

  /// Part of a drawing: 'marker' or 'line'
  final String drawingPart;

  /// Starting epoch.
  final int startEpoch;

  /// Starting Y coordinates. y0 in SmartCharts
  final double startYCoord;

  /// Ending epoch.
  final int endEpoch;

  /// Ending Y coordinates. y1 in SmartCharts
  final double endYCoord;

  /// Marker radius.
  final double markerRadius = 4;

  /// Paint
  @override
  void onPaint(Canvas canvas, Size size, ChartTheme theme,
      double Function(int x) epochToX, DrawingToolConfig config) {
    final LineStyle fillStyle = config.toJson()['fillStyle'];
    final LineStyle lineStyle = config.toJson()['lineStyle'];
    final String pattern = config.toJson()['pattern'];
    if (drawingPart == 'marker') {
      final double startXCoord = epochToX(startEpoch);
      canvas.drawCircle(Offset(startXCoord, startYCoord), markerRadius,
          Paint()..color = lineStyle.color);
    } else if (drawingPart == 'line') {
      final double startXCoord = epochToX(startEpoch); // x0 in SmartCharts
      final double endXCoord = epochToX(endEpoch); // x1 in SmartCharts
      final double x = (min(startXCoord, endXCoord)).round() + 0.5;
      final double y = min(startYCoord, endYCoord);
      double width = max(startXCoord, endXCoord) - x;
      double height = max(startYCoord, endYCoord) - y;
      width = width == 0 ? 1 : width;
      height = height == 0 ? 1 : height;

      if (pattern == 'solid') {
        canvas.drawRect(
            Offset(x, y) & Size(width, height),
            Paint()
              ..color = lineStyle.color
              ..style = PaintingStyle.stroke
              ..strokeWidth = lineStyle.thickness);
        if (fillStyle.color != Colors.transparent) {
          // fill the rectangle:
          canvas.drawRect(
              Offset(x, y) & Size(width, height),
              Paint()
                ..color = fillStyle.color
                ..style = PaintingStyle.fill
                ..strokeWidth = lineStyle.thickness);
        }
      }
    }
  }
}
