import 'package:deriv_chart/src/misc/extensions.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converts `Color` to and from JSON.
///
/// Usage:
/// ```
///   @JsonSerializable()
///   @ColorConverter()
///   class SomeDataClass {
///     ...
///     final Color color;
///     ...
///   }
/// ```
class ColorConverter implements JsonConverter<Color, int> {
  /// Initializes
  const ColorConverter();

  @override
  Color fromJson(int value) => Color(value);

  @override
  int toJson(Color color) => color.toInt32;
}
