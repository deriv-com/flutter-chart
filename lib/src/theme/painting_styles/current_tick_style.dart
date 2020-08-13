import 'package:flutter/cupertino.dart';

class CurrentTickStyle {
  CurrentTickStyle({
    this.labelColor,
    this.dotFillColor,
    this.dotOpaqueColor,
    this.lineColor,
    this.dashedLine,
    this.dotCircle,
  });

  final Color labelColor;
  final Color dotFillColor;
  final Color dotOpaqueColor;
  final Color lineColor;
  final bool dashedLine;
  final double dotCircle;
}
