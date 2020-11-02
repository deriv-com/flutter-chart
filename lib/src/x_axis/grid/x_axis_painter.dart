import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:flutter/cupertino.dart';

/// XAxis CustomPainter super-class.
abstract class XAxisPainter extends CustomPainter {
  /// Initializes
  XAxisPainter({
    @required this.gridLineCoords,
    @required this.epochToCanvasX,
    @required this.style,
  });

  /// Grids lines x coordinates.
  final List<double> gridLineCoords;

  /// X-Axis conversion function for epoch -> x
  final double Function(int) epochToCanvasX;

  /// Chart's grid style
  final GridStyle style;

  @override
  bool shouldRepaint(XAxisPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(XAxisPainter oldDelegate) => false;
}
