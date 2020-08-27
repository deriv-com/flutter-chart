import 'package:deriv_chart/src/x_axis/grid/time_grid.dart';
import 'package:flutter/material.dart';

import 'paint_x_grid.dart';

class XGridPainter extends CustomPainter {
  XGridPainter({
    @required this.gridTimestamps,
    @required this.epochToCanvasX,
  });

  final List<DateTime> gridTimestamps;
  final double Function(int) epochToCanvasX;

  @override
  void paint(Canvas canvas, Size size) {
    paintXGrid(
      canvas,
      size,
      timeLabels: gridTimestamps.map((time) => timeLabel(time)).toList(),
      xCoords: gridTimestamps
          .map((time) => epochToCanvasX(time.millisecondsSinceEpoch))
          .toList(),
    );
  }

  @override
  bool shouldRepaint(XGridPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(XGridPainter oldDelegate) => false;
}
