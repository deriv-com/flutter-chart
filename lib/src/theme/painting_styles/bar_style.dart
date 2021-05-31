import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:deriv_chart/src/theme/painting_styles/data_series_style.dart';

/// Defines the style of painting histogram bar.
class BarStyle extends DataSeriesStyle with EquatableMixin {
  /// Initializes a style that defines the style of painting histogram data.
  const BarStyle({
    this.positiveColor = const Color(0xFF00A79E),
    this.negativeColor = const Color(0xFFCC2E3D),
  });

  /// Color of histogram bar in which the price moved HIGHER than the last epoch.
  final Color positiveColor;

  /// Color of histogram bar in which the price moved LOWER than the last epoch.
  final Color negativeColor;

  @override
  String toString() => '${super.toString()}$positiveColor, $negativeColor';

  @override
  List<Object> get props => <Color>[positiveColor, negativeColor];
}
