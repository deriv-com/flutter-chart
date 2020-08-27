import 'package:deriv_chart/src/logic/time_grid.dart';
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
  });

  final int pipSize;

  final List<DateTime> gridTimestamps;
  final List<double> gridLineQuotes;

  /// Width of the area where quote labels and current tick arrow are painted.
  final double quoteLabelsAreaWidth;

  final double Function(int) epochToCanvasX;
  final double Function(double) quoteToCanvasY;

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

    paintYGrid(
      canvas,
      size,
      quoteLabels: gridLineQuotes
          .map((quote) => quote.toStringAsFixed(pipSize))
          .toList(),
      yCoords: gridLineQuotes.map((quote) => quoteToCanvasY(quote)).toList(),
      quoteLabelsAreaWidth: quoteLabelsAreaWidth,
    );
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(GridPainter oldDelegate) => false;
}
