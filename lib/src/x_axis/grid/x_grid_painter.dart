import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:deriv_chart/src/x_axis/grid/x_axis_painter.dart';
import 'package:flutter/material.dart';

import 'paint_x_grid.dart';

/// Paint X-Axis grid lines
class XGridPainter extends XAxisPainter {
  /// Initializes
  XGridPainter({
    List<DateTime> gridTimestamps,
    double Function(int) epochToCanvasX,
    GridStyle style,
  }) : super(
          gridTimestamps: gridTimestamps,
          epochToCanvasX: epochToCanvasX,
          style: style,
        );

  @override
  void paint(Canvas canvas, Size size) => paintTimeGridLines(
        canvas,
        size,
        gridTimestamps
            .map((DateTime time) => epochToCanvasX(time.millisecondsSinceEpoch))
            .toList(),
        style,
      );
}
