import 'package:deriv_chart/src/helpers/color_converter.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'data_series_style.dart';

part 'scatter_style.g.dart';

/// Defines the style of painting Scatter data.
@JsonSerializable()
@ColorConverter()
class ScatterStyle extends DataSeriesStyle {
  /// Initializes a style that defines the style of painting line data.
  const ScatterStyle({
    this.color = const Color(0xFF85ACB0),
    this.radius = 1.5,
  });

  /// Initializes from JSON.
  factory ScatterStyle.fromJson(Map<String, dynamic> json) =>
      _$ScatterStyleFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ScatterStyleToJson(this);

  /// Dot color.
  final Color color;

  /// Dot radius.
  final double radius;

  /// Creates a copy of this object.
  ScatterStyle copyWith({
    Color? color,
    double? radius,
  }) =>
      ScatterStyle(
        color: color ?? this.color,
        radius: radius ?? this.radius,
      );

  @override
  String toString() => '${super.toString()}$color, $radius';
}
