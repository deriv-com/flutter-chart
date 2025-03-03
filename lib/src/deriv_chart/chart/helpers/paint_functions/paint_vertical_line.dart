import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';

/// Paints vertical line
void paintVerticalLine(
  Canvas canvas,
  Offset point1,
  Offset point2,
  Color color,
  double lineThickness, {
  double dashWidth = 3,
  double dashSpace = 3,
}) {
  final Offset _topOffset = point1.dy < point2.dy ? point1 : point2;
  final Offset _bottomOffset = point1.dy > point2.dy ? point1 : point2;

  paintVerticalDashedLine(
    canvas,
    point1.dx,
    _topOffset.dy,
    _bottomOffset.dy,
    color,
    lineThickness,
    dashWidth: 2,
    dashSpace: 2,
  );
}
