import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';

import 'paint_x_grid.dart';

/// Paints x-axis grid and labels.
class XGridPainter extends CustomPainter {
  /// Creates x-axis painter.
  XGridPainter({
    required this.xCoords,
    required this.style,
    required this.timestamps,
    required this.msPerPx,
  });

  /// X-coordinates of time labels.
  final List<double> xCoords;

  /// Style of the grid.
  final ChartTheme style;

  /// List of DateTime on screen
  final List<DateTime> timestamps;

  /// Specifies the zoom level of the chart.
  final double msPerPx;

  @override
  void paint(Canvas canvas, Size size) {
    if (timestamps.isEmpty || xCoords.isEmpty) {
      return;
    }

    paintXGrid(
      canvas,
      size,
      timestamps: timestamps,
      xCoords: xCoords,
      style: style,
      msPerPx: msPerPx,
    );
  }

  @override
  bool shouldRepaint(XGridPainter oldDelegate) =>
      timestamps != oldDelegate.timestamps ||
      xCoords != oldDelegate.xCoords ||
      style != oldDelegate.style;

  @override
  bool shouldRebuildSemantics(XGridPainter oldDelegate) => false;
}
