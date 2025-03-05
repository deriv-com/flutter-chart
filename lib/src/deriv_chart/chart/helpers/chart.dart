import 'dart:math';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';

/// Calculates the width of yAxis
double calculateYAxisWidth(List<Tick> ticks, ChartTheme theme, int pipSize) {
  if (ticks.isEmpty) {
    return 60;
  } else {
    final double width = labelWidth(
      ticks.last.close,
      theme.gridStyle.yLabelStyle,
      pipSize,
    );

    return width + theme.gridStyle.labelHorizontalPadding * 2;
  }
}

/// Calculates the width of current tick
double calculateCurrentTickWidth(
    List<Tick> ticks, TextStyle textStyle, int pipSize) {
  if (ticks.isEmpty) {
    return 60;
  } else {
    final double width = labelWidth(
      ticks.last.close,
      textStyle,
      pipSize,
    );

    return width + 4 * 2 + 3;
  }
}

/// Calculates opacity of the markers
double calculateOpacity(
  double from,
  double? exitTo,
) {
  if (exitTo != null) {
    return min(max(exitTo - from - 10, 0) / 6, 1);
  }
  return 1;
}
