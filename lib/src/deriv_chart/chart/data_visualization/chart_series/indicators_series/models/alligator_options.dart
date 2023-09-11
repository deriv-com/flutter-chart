import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import 'indicator_options.dart';

/// Alligator indicator options.
class AlligatorOptions extends IndicatorOptions {
  /// Initializes
  const AlligatorOptions({
    this.jawPeriod = 13,
    this.teethPeriod = 8,
    this.lipsPeriod = 5,
    this.showLines = true,
    this.showFractal = false,
    this.jawOffset = 8,
    this.teethOffset = 5,
    this.lipsOffset = 3,
    this.jawLineStyle = const LineStyle(color: Colors.blue),
    this.teethLineStyle = const LineStyle(color: Colors.red),
    this.lipsLineStyle = const LineStyle(color: Colors.green),
    bool showLastIndicator = false,
  }) : super(showLastIndicator: showLastIndicator);

  /// Smoothing period for jaw series
  final int jawPeriod;

  /// Smoothing period for teeth series
  final int teethPeriod;

  /// Smoothing period for lips series
  final int lipsPeriod;

  /// show alligator lins  or not
  final bool showLines;

  /// show fractal indicator or not
  final bool showFractal;

  /// Shift to future in jaw series
  final int jawOffset;

  /// Shift to future in teeth series
  final int teethOffset;

  /// Shift to future in lips series
  final int lipsOffset;

  /// Jaw line style.
  final LineStyle jawLineStyle;

  /// Teeth line style.
  final LineStyle teethLineStyle;

  /// Lips line style.
  final LineStyle lipsLineStyle;

  @override
  List<Object> get props => <Object>[
        jawPeriod,
        teethPeriod,
        lipsPeriod,
        showLines,
        showFractal,
        jawOffset,
        teethOffset,
        lipsOffset,
        jawLineStyle,
        teethLineStyle,
        lipsLineStyle,
      ];
}
