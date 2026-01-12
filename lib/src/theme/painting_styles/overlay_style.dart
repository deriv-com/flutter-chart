import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'overlay_style.g.dart';

/// Style of the overlay.
@JsonSerializable()
class OverlayStyle extends Equatable {
  /// Initializes a barrier style
  const OverlayStyle({
    this.labelHeight = 24,
    this.color = const Color(0xFF00A79E),
    this.textStyle = const TextStyle(
      fontSize: 10,
      height: 1.3,
      fontWeight: FontWeight.normal,
      color: Colors.white,
      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    ),
  });

  /// Initializes from JSON.
  factory OverlayStyle.fromJson(Map<String, dynamic> json) =>
      _$OverlayStyleFromJson(json);

  /// Height of the label.
  final double labelHeight;

  /// Color of the overlay barriers.
  @JsonKey(
    fromJson: _colorFromJson,
    toJson: _colorToJson,
  )
  final Color color;

  /// Style of the text used in the overlay.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final TextStyle textStyle;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => _$OverlayStyleToJson(this);

  /// Creates a copy of this object.
  OverlayStyle copyWith({
    double? labelHeight,
    Color? color,
    TextStyle? textStyle,
  }) =>
      OverlayStyle(
        labelHeight: labelHeight ?? this.labelHeight,
        color: color ?? this.color,
        textStyle: textStyle ?? this.textStyle,
      );

  @override
  String toString() => '${super.toString()} $labelHeight, $color, $textStyle';

  @override
  List<Object?> get props => <Object?>[labelHeight, color, textStyle];
}

/// Converts a Color to JSON representation.
int _colorToJson(Color color) => color.value;

/// Converts JSON representation to a Color.
Color _colorFromJson(int value) => Color(value);
