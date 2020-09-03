import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:flutter/material.dart';

import 'paint_x_grid.dart';
import 'time_label.dart';

class XGridPainter extends CustomPainter {
  XGridPainter({
    @required this.gridTimestamps,
    @required this.epochToCanvasX,
    @required this.style,
  });

  final List<DateTime> gridTimestamps;
  final double Function(int) epochToCanvasX;
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
