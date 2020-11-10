import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:flutter/material.dart';

import 'paint_x_grid.dart';
import 'time_label.dart';

/// Paints x-axis grid and labels.
class XGridPainter extends CustomPainter {
  /// Creates x-axis painter.
  XGridPainter({
    @required this.gridTimestamps,
    @required this.epochToCanvasX,
    @required this.style,
  });

  /// Timestamps of vertical grid lines.
  final List<DateTime> gridTimestamps;

  /// Epoch to x-coordinate convertion function.
  final double Function(int) epochToCanvasX;

  /// Style of the grid.
  final GridStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    paintXGrid(
      canvas,
      size,
      timeLabels: gridTimestamps.map((time) => timeLabel(time)).toList(),
      xCoords: gridTimestamps
          .map((time) => epochToCanvasX(time.millisecondsSinceEpoch))
          .toList(),
      style: style,
    );
  }

  @override
  bool shouldRepaint(XGridPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(XGridPainter oldDelegate) => false;
}
