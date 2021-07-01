import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/helpers/color_converter.dart';
import 'package:equatable/equatable.dart';
import 'package:deriv_chart/src/theme/painting_styles/data_series_style.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bar_style.g.dart';

/// Defines the style of painting histogram bar.
@JsonSerializable()
@ColorConverter()
class BarStyle extends DataSeriesStyle with EquatableMixin {
  /// Initializes a style that defines the style of painting histogram data.
  const BarStyle({
    this.positiveColor = const Color(0xFF4CAF50),
    this.negativeColor = const Color(0xFFCC2E3D),
  });

  /// Initializes from JSON.
  factory BarStyle.fromJson(Map<String, dynamic> json) =>
      _$BarStyleFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BarStyleToJson(this);

  /// Color of histogram bar in which the price moved HIGHER than the last epoch.
  final Color positiveColor;

  /// Color of histogram bar in which the price moved LOWER than the last epoch.
  final Color negativeColor;

  /// Creates a copy of this object.
  BarStyle copyWith({
    Color? positiveColor,
    Color? negativeColor,
  }) =>
      BarStyle(
        positiveColor: positiveColor ?? const Color(0xFF4CAF50),
        negativeColor: negativeColor ??  const Color(0xFFCC2E3D),

      );

  @override
  String toString() => '${super.toString()}$positiveColor, $negativeColor';

  @override
  List<Object> get props => <Color>[positiveColor, negativeColor];
}
