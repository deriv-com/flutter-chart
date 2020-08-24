// ignore_for_file: public_member_api_docs

import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

import 'colors.dart';
import 'text_styles.dart';

/// A default implementation of [ChartTheme] which provides access to
/// theme-related details for the chart package.
abstract class ChartDefaultTheme implements ChartTheme {
  final Map<TextStyle, Map<Color, TextStyle>> _textStyle =
      <TextStyle, Map<Color, TextStyle>>{};

  @override
  String get fontFamily => TextStyles.appFontFamily;

  @override
  TextStyle get caption2 => TextStyles.caption2;

  @override
  Color get brandCoralColor => BrandColors.coral;

  @override
  Color get brandGreenishColor => BrandColors.greenish;

  @override
  Color get brandOrangeColor => BrandColors.orange;

  TextStyle _getStyle({
    @required TextStyle textStyle,
    @required Color color,
  }) {
    ArgumentError.checkNotNull(textStyle, 'textStyle');
    ArgumentError.checkNotNull(color, 'color');

    _textStyle.putIfAbsent(textStyle, () => <Color, TextStyle>{});
    _textStyle[textStyle]
        .putIfAbsent(color, () => textStyle.copyWith(color: color));

    return _textStyle[textStyle][color];
  }

  @override
  TextStyle textStyle({
    @required TextStyle textStyle,
    Color color,
  }) {
    ArgumentError.checkNotNull(textStyle, 'textStyle');

    color ??= DarkThemeColors.base01;

    return _getStyle(textStyle: textStyle, color: color);
  }
}
