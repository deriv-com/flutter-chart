import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:flutter/cupertino.dart';

///
abstract class XAxisPainter extends CustomPainter {
  XAxisPainter({
    @required this.gridTimestamps,
    @required this.epochToCanvasX,
    @required this.style,
  });

  final List<DateTime> gridTimestamps;
  final double Function(int) epochToCanvasX;
  final GridStyle style;

  @override
  bool shouldRepaint(XAxisPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(XAxisPainter oldDelegate) => false;
}
