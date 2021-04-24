// @dart=2.9

import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:flutter/material.dart';

import 'paint_x_grid.dart';

/// Paints x-axis grid and labels.
class XGridPainter extends CustomPainter {
  /// Creates x-axis painter.
  XGridPainter({
    @required this.timeLabels,
    @required this.xCoords,
    @required this.style,
  });

  /// Time labels.
  final List<String> timeLabels;

  /// X-coordinates of time labels.
  final List<double> xCoords;

  /// Style of the grid.
  final GridStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    if (timeLabels == null || xCoords == null) {
      return;
    }

    paintXGrid(
      canvas,
      size,
      timeLabels: timeLabels,
      xCoords: xCoords,
      style: style,
    );
  }

  @override
  bool shouldRepaint(XGridPainter oldDelegate) =>
      timeLabels != oldDelegate.timeLabels ||
      xCoords != oldDelegate.xCoords ||
      style != oldDelegate.style;

  @override
  bool shouldRebuildSemantics(XGridPainter oldDelegate) => false;
}
