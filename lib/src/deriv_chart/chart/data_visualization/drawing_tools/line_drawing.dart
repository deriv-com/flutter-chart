import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:flutter/material.dart';

import '../../../../../deriv_chart.dart';
import 'drawing.dart';

/// Line drawing tool. A line is a vector defined by two points that is
/// infinite in both directions.

class LineDrawing extends Drawing {
  /// initializes
  LineDrawing({
    required this.drawingPart,
    this.startEpoch = 0,
    this.startYCoord = 0,
    this.endEpoch = 0,
    this.endYCoord = 0,
  });

  /// 'marker' or 'line'
  final String drawingPart;

  /// starting epoch
  final int? startEpoch;

  /// starting Y coordinates
  final double? startYCoord;

  /// ending epoch
  final int? endEpoch;

  /// ending Y coordinates
  final double? endYCoord;

  /// marker radius
  final double markerRadius = 4;

  /// paint
  @override
  void onPaint(Canvas canvas, Size size, ChartTheme theme,
      double Function(int x) epochToX, DrawingToolConfig config) {
    final LineStyle lineStyle = config.toJson()['lineStyle'];
    final String pattern = config.toJson()['pattern'];
    if (drawingPart == 'marker') {
      if (startEpoch != null && startYCoord != null) {
        final double startXCoord = epochToX(startEpoch!);
        canvas.drawCircle(Offset(startXCoord, startYCoord!), markerRadius,
            Paint()..color = lineStyle.color);
      }
    } else if (drawingPart == 'line') {
      if (startEpoch != null &&
          endEpoch != null &&
          startYCoord != null &&
          endYCoord != null) {
        final double startXCoord = epochToX(startEpoch!);
        final double endXCoord = epochToX(endEpoch!);

        /// based on calculateOuterSet() from SmartCharts
        Map<String, double?> vector = <String, double?>{
          'x0': startXCoord,
          'y0': startYCoord,
          'x1': endXCoord,
          'y1': endYCoord
        };
        if (vector['x0']! > vector['x1']!) {
          vector = <String, double?>{
            'x0': endXCoord,
            'y0': endYCoord!,
            'x1': startXCoord,
            'y1': startYCoord!
          };
        }
        final double earlier = vector['x0']! - 1000;
        final double later = vector['x1']! + 1000;

        final double startY = getYIntersection(vector, earlier) ?? 0,
            endingY = getYIntersection(vector, later) ?? 0,
            startX = earlier,
            endingX = later;

        if (pattern == 'solid') {
          canvas.drawLine(
              Offset(startX, startY),
              Offset(endingX, endingY),
              Paint()
                ..color = lineStyle.color
                ..strokeWidth = lineStyle.thickness);
        }
      }
    }
  }
}
