import 'package:deriv_chart/src/deriv_chart/chart/helpers/color_converter.dart';
import 'package:deriv_chart/src/theme/painting_styles/data_series_style.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'line_style.g.dart';

/// Defines the style of painting line data.
@JsonSerializable()
@ColorConverter()
class LineStyle extends DataSeriesStyle with EquatableMixin {
  /// Initializes a style that defines the style of painting line data.
  const LineStyle({
    this.color = const Color(0xFF85ACB0),
    this.thickness = 1,
    this.hasArea = false,
  });

  /// Initializes from JSON.
  factory LineStyle.fromJson(Map<String, dynamic> json) =>
      _$LineStyleFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LineStyleToJson(this);

  /// Line color.
  final Color color;

  /// Line thickness.
  final double thickness;

  /// Whether the line series has area or not.
  final bool hasArea;

  /// Creates a copy of this object.
  LineStyle copyWith({
    Color? color,
    double? thickness,
    bool? hasArea,
  }) =>
      LineStyle(
        color: color ?? this.color,
        thickness: thickness ?? this.thickness,
        hasArea: hasArea ?? this.hasArea,
      );

  @override
  String toString() => '${super.toString()}$color, $thickness, $hasArea';

  @override
  List<Object> get props => [color, thickness, hasArea];
}
