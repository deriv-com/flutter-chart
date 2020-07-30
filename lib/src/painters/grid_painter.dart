import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter/material.dart';

import '../paint/paint_grid.dart';

class GridPainter extends CustomPainter {
  GridPainter({
    @required this.gridLineEpochs,
    @required this.gridLineQuotes,
    @required this.quoteLabelsAreaWidth,
    @required this.pipSize,
    @required this.epochToCanvasX,
    @required this.quoteToCanvasY,
  });

  final int pipSize;

  final List<int> gridLineEpochs;
  final List<double> gridLineQuotes;

  /// Width of the area where quote labels and current tick arrow are painted.
  final double quoteLabelsAreaWidth;

  final double Function(int) epochToCanvasX;
  final double Function(double) quoteToCanvasY;

  @override
  void paint(Canvas canvas, Size size) {
    paintGrid(
      canvas,
      size,
      timeLabels: gridLineEpochs.map((epoch) {
        final time = DateTime.fromMillisecondsSinceEpoch(epoch);
        return DateFormat('Hms').format(time);
      }).toList(),
      quoteLabels: gridLineQuotes
          .map((quote) => quote.toStringAsFixed(pipSize))
          .toList(),
      xCoords: gridLineEpochs.map((epoch) => epochToCanvasX(epoch)).toList(),
      yCoords: gridLineQuotes.map((quote) => quoteToCanvasY(quote)).toList(),
      quoteLabelsAreaWidth: quoteLabelsAreaWidth,
    );
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(GridPainter oldDelegate) => false;
}
