import 'package:flutter/painting.dart';
import 'package:json_annotation/json_annotation.dart';

/// JsonConverter for TextStyle
class TextStyleJsonConverter
    implements JsonConverter<TextStyle, Map<String, dynamic>> {
  /// Constructor
  const TextStyleJsonConverter();

  @override
  TextStyle fromJson(Map<String, dynamic> json) {
    return TextStyle(
      color: json['color'] != null ? Color(json['color'] as int) : null,
      fontSize: json['fontSize'] as double?,
      fontWeight: json['fontWeight'] != null
          ? FontWeight.values[json['fontWeight'] as int]
          : null,
      fontStyle: json['fontStyle'] != null
          ? FontStyle.values[json['fontStyle'] as int]
          : null,
      letterSpacing: json['letterSpacing'] as double?,
      wordSpacing: json['wordSpacing'] as double?,
      height: json['height'] as double?,
      decoration: json['decoration'] != null
          ? _getTextDecorationFromInt(json['decoration'] as int)
          : null,
      decorationColor: json['decorationColor'] != null
          ? Color(json['decorationColor'] as int)
          : null,
      decorationStyle: json['decorationStyle'] != null
          ? TextDecorationStyle.values[json['decorationStyle'] as int]
          : null,
      decorationThickness: json['decorationThickness'] as double?,
    );
  }

  @override
  Map<String, dynamic> toJson(TextStyle textStyle) {
    return <String, dynamic>{
      if (textStyle.color != null) 'color': textStyle.color!.value,
      if (textStyle.fontSize != null) 'fontSize': textStyle.fontSize,
      if (textStyle.fontWeight != null)
        'fontWeight': textStyle.fontWeight!.index,
      if (textStyle.fontStyle != null) 'fontStyle': textStyle.fontStyle!.index,
      if (textStyle.letterSpacing != null)
        'letterSpacing': textStyle.letterSpacing,
      if (textStyle.wordSpacing != null) 'wordSpacing': textStyle.wordSpacing,
      if (textStyle.height != null) 'height': textStyle.height,
      if (textStyle.decoration != null)
        'decoration': _getIntFromTextDecoration(textStyle.decoration!),
      if (textStyle.decorationColor != null)
        'decorationColor': textStyle.decorationColor!.value,
      if (textStyle.decorationStyle != null)
        'decorationStyle': textStyle.decorationStyle!.index,
      if (textStyle.decorationThickness != null)
        'decorationThickness': textStyle.decorationThickness,
    };
  }

  /// Convert int to TextDecoration
  TextDecoration _getTextDecorationFromInt(int value) {
    switch (value) {
      case 0:
        return TextDecoration.none;
      case 1:
        return TextDecoration.underline;
      case 2:
        return TextDecoration.overline;
      case 3:
        return TextDecoration.lineThrough;
      default:
        return TextDecoration.none;
    }
  }

  /// Convert TextDecoration to int
  int _getIntFromTextDecoration(TextDecoration decoration) {
    if (decoration == TextDecoration.none) {
      return 0;
    }
    if (decoration == TextDecoration.underline) {
      return 1;
    }
    if (decoration == TextDecoration.overline) {
      return 2;
    }
    if (decoration == TextDecoration.lineThrough) {
      return 3;
    }
    return 0;
  }
}
