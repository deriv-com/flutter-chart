import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:flutter/cupertino.dart';

/// XAxis CustomPainter super-class.
abstract class XAxisPainter extends CustomPainter {
  /// Initializes
  XAxisPainter({
    @required this.gridTimestamps,
    @required this.epochToCanvasX,
    @required this.style,
  });

  /// Grids and labels timestamps
  final List<DateTime> gridTimestamps;

  /// X-Axis conversion function for epoch -> x
  final double Function(int) epochToCanvasX;

  /// Chart's grid style
  final GridStyle style;

  @override
  bool shouldRepaint(XAxisPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(XAxisPainter oldDelegate) => false;
}
