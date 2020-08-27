import 'package:flutter/material.dart';

import '../paint/paint_grid.dart';

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
