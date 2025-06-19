import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';

import 'functions/helper_functions.dart';

/// Returns the last indicator style.
HorizontalBarrierStyle? getLastIndicatorStyle(
  Color color, {
  bool showLastIndicator = false,
}) {
  if (showLastIndicator) {
    return HorizontalBarrierStyle(
      color: color,
      labelShapeBackgroundColor: color,
      hasLine: false,
      textStyle: TextStyle(
        fontSize: 10,
        height: 1.3,
        fontWeight: FontWeight.normal,
        color: calculateTextColor(color),
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      ),
    );
  }
  return null;
}
