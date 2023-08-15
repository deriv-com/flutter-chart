import 'package:flutter/material.dart';

/// Find intersection point of two lines.
///
/// [p1] is first point of line 1.
/// [p2] is second point of line 1.
/// [p3] is first point of line 2.
/// [p4] is second point of line 2.
Offset? findIntersection(Offset p1, Offset p2, Offset p3, Offset p4) {
  if ((p1.dx == p2.dx && p1.dy == p2.dy) ||
      (p3.dx == p4.dx && p3.dy == p4.dy)) {
    return null;
  }

  final double denominator =
      (p4.dy - p3.dy) * (p2.dx - p1.dx) - (p4.dx - p3.dx) * (p2.dy - p1.dy);

  if (denominator == 0) {
    return null;
  }

  final double ua =
      ((p4.dx - p3.dx) * (p1.dy - p3.dy) - (p4.dy - p3.dy) * (p1.dx - p3.dx)) /
          denominator;
  final double ub =
      ((p2.dx - p1.dx) * (p1.dy - p3.dy) - (p2.dy - p1.dy) * (p1.dx - p3.dx)) /
          denominator;

  if (ua < 0 || ua > 1 || ub < 0 || ub > 1) {
    return null;
  }

  final double x = p1.dx + ua * (p2.dx - p1.dx);
  final double y = p1.dy + ua * (p2.dy - p1.dy);

  return Offset(x, y);
}
