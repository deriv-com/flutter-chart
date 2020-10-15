import 'package:flutter/material.dart';

/// Returns the path of a pentagon shaped label.
Path getCurrentTickLabelBackgroundPath({
  @required double left,
  @required double top,
  @required double right,
  @required double bottom,
  double arrowWidth = 10,
  double radius = 4,
}) =>
    Path()
      ..moveTo(right - radius, bottom)
      ..quadraticBezierTo(right, bottom, right, bottom - radius)
      ..lineTo(right, top + radius)
      ..quadraticBezierTo(right, top, right - radius, top)
      ..lineTo(left + radius, top)
      ..cubicTo(
        left,
        top,
        left - radius,
        top + radius,
        left - arrowWidth,
        top + (bottom - top) / 2,
      )
      ..cubicTo(
        left - radius,
        bottom - radius,
        left,
        bottom,
        left + radius,
        bottom,
      );
