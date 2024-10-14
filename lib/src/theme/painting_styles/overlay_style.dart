import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Style of the overlay.
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

  /// Height of the label.
  final double labelHeight;

  /// Color of the overlay barriers.
  final Color color;

  /// Style of the text used in the overlay.
  final TextStyle textStyle;

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
