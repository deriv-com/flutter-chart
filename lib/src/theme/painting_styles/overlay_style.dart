import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Style of the overlay.
class OverlayStyle extends Equatable {
  /// Initializes a barrier style
  const OverlayStyle({
    this.labelHeight = 24,
    this.color = const Color(0xFF00A79E),
    this.secondaryColor = const Color(0xFF607D8B),
    this.hasLine = false,
    this.isDashed = true,
    this.buttonStyle = const ButtonStyle(),
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

  /// Color of the secondary color.
  final Color secondaryColor;

  /// Whether the overlay needs lines to axes.
  final bool hasLine;

  /// Whether the overlay line should be dashed or solid. If true, the line is
  /// dashed. Otherwise, the line is solid.
  final bool isDashed;

  /// Style of the button used in the overlay.
  final ButtonStyle buttonStyle;

  /// Style of the text used in the overlay.
  final TextStyle textStyle;

  /// Creates a copy of this object.
  OverlayStyle copyWith({
    double? labelHeight,
    Color? color,
    Color? secondaryColor,
    bool? hasLine,
    bool? isDashed,
    ButtonStyle? buttonStyle,
    TextStyle? textStyle,
  }) =>
      OverlayStyle(
        labelHeight: labelHeight ?? this.labelHeight,
        color: color ?? this.color,
        secondaryColor: secondaryColor ?? this.secondaryColor,
        hasLine: hasLine ?? this.hasLine,
        isDashed: isDashed ?? this.isDashed,
        buttonStyle: buttonStyle ?? this.buttonStyle,
        textStyle: textStyle ?? this.textStyle,
      );

  @override
  String toString() =>
      '${super.toString()}$color, $secondaryColor, $hasLine, $isDashed, '
      '$buttonStyle, $textStyle';

  @override
  List<Object?> get props => <Object?>[
        labelHeight,
        color,
        secondaryColor,
        hasLine,
        isDashed,
        buttonStyle,
        textStyle,
      ];
}
