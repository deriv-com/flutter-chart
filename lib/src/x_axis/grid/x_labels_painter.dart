import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:deriv_chart/src/x_axis/grid/x_axis_painter.dart';
import 'package:flutter/material.dart';

import 'paint_x_grid.dart';
import 'time_label.dart';

/// Paints X-Axis time labels
class XLabelsPainter extends XAxisPainter {
  /// Initializes
  XLabelsPainter({
    List<DateTime> gridTimestamps,
    double Function(int) epochToCanvasX,
    GridStyle style,
  }) : super(
          gridTimestamps: gridTimestamps,
          epochToCanvasX: epochToCanvasX,
          style: style,
        );

  @override
  void paint(Canvas canvas, Size size) => paintTimeLabels(
        canvas,
        size,
        timeLabels:
            gridTimestamps.map((DateTime time) => timeLabel(time)).toList(),
        xCoords: gridTimestamps
            .map((DateTime time) => epochToCanvasX(time.millisecondsSinceEpoch))
            .toList(),
        style: style,
      );
}
