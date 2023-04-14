import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/vector.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';
import '../drawing.dart';

/// Line drawing tool. A line is a vector defined by two points that is
/// infinite in both directions.
class LineDrawing extends Drawing {
  /// Initializes
  LineDrawing({
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

  /// Starting Y coordinates.
  final double startYCoord;

  /// Ending epoch.
  final int endEpoch;

  /// Ending Y coordinates.
  final double endYCoord;

  /// Marker radius.
  final double markerRadius = 4;

  /// Paint
  @override
  void onPaint(
    Canvas canvas,
    Size size,
    ChartTheme theme,
    double Function(int x) epochToX,
    double Function(double y) quoteToY,
    DrawingToolConfig config,
    Offset draggedPosition,
  ) {
    final LineStyle lineStyle = config.toJson()['lineStyle'];
    final String pattern = config.toJson()['pattern'];
    final double startQuoteToY = quoteToY(startYCoord);
    final double endQuoteToY = quoteToY(endYCoord);

    if (drawingPart == 'marker') {
      final double startXCoord = epochToX(startEpoch);

      canvas.drawCircle(Offset(startXCoord, startQuoteToY), markerRadius,
          Paint()..color = lineStyle.color);
    } else if (drawingPart == 'line') {
      final double startXCoord = epochToX(startEpoch);
      final double endXCoord = epochToX(endEpoch);

      /// Based on calculateOuterSet() from SmartCharts
      Vector vec = Vector(
        x0: startXCoord,
        y0: startQuoteToY,
        x1: endXCoord,
        y1: endQuoteToY,
      );
      if (vec.x0! > vec.x1!) {
        vec = Vector(
          x0: endXCoord,
          y0: endQuoteToY,
          x1: startXCoord,
          y1: startQuoteToY,
        );
      }

      final double earlier = vec.x0! - 1000;
      final double later = vec.x1! + 1000;

      final double startY = getYIntersection(vec, earlier) ?? 0,
          endingY = getYIntersection(vec, later) ?? 0,
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
