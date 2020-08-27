import 'package:deriv_chart/src/logic/time_grid.dart';
import 'package:flutter/material.dart';

import '../paint/paint_grid.dart';

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

class YGridPainter extends CustomPainter {
  YGridPainter({
    @required this.gridLineQuotes,
    @required this.quoteLabelsAreaWidth,
    @required this.pipSize,
    @required this.quoteToCanvasY,
  });

  final int pipSize;
  final List<double> gridLineQuotes;

  /// Width of the area where quote labels and current tick arrow are painted.
  final double quoteLabelsAreaWidth;

  final double Function(double) quoteToCanvasY;

  @override
  void paint(Canvas canvas, Size size) {
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
  bool shouldRepaint(YGridPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(YGridPainter oldDelegate) => false;
}
