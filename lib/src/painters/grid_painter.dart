import 'package:deriv_chart/src/logic/time_grid.dart';
import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:flutter/material.dart';

import '../paint/paint_grid.dart';

class GridPainter extends CustomPainter {
  GridPainter({
    @required this.gridTimestamps,
    @required this.gridLineQuotes,
    @required this.quoteLabelsAreaWidth,
    @required this.pipSize,
    @required this.epochToCanvasX,
    @required this.quoteToCanvasY,
    @required this.style,
  });

  final int pipSize;

  final List<DateTime> gridTimestamps;
  final List<double> gridLineQuotes;

  /// Width of the area where quote labels and current tick arrow are painted.
  final double quoteLabelsAreaWidth;

  final double Function(int) epochToCanvasX;
  final double Function(double) quoteToCanvasY;

  final GridStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    paintGrid(
      canvas,
      size,
      timeLabels: gridTimestamps.map((time) => timeLabel(time)).toList(),
      quoteLabels: gridLineQuotes
          .map((quote) => quote.toStringAsFixed(pipSize))
          .toList(),
      xCoords: gridTimestamps
          .map((time) => epochToCanvasX(time.millisecondsSinceEpoch))
          .toList(),
      yCoords: gridLineQuotes.map((quote) => quoteToCanvasY(quote)).toList(),
      quoteLabelsAreaWidth: quoteLabelsAreaWidth,
      style: style,
    );
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(GridPainter oldDelegate) => false;
}
