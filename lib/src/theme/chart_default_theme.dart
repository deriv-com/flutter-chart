// ignore_for_file: public_member_api_docs

import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'colors.dart';
import 'text_styles.dart';

/// A default implementation of [ChartTheme] which provides access to
/// theme-related details for the chart package.
class ChartDefaultTheme extends ChartTheme {
  factory ChartDefaultTheme() => _instance;

  ChartDefaultTheme._internal();

  static final ChartDefaultTheme _instance = ChartDefaultTheme._internal();

  final Map<TextStyle, Map<Color, TextStyle>> _textStyle =
      <TextStyle, Map<Color, TextStyle>>{};

  bool _isDarkTheme =
      SchedulerBinding.instance.window.platformBrightness == Brightness.dark;

  @override
  bool get isDarkTheme => _isDarkTheme;

  @override
  String get fontFamily => TextStyles.appFontFamily;

  @override
  Color get brandCoralColor => BrandColors.coral;

  @override
  Color get brandGreenishColor => BrandColors.greenish;

  @override
  Color get brandOrangeColor => BrandColors.orange;

  @override
  Color get accentRedColor =>
      _isDarkTheme ? DarkThemeColors.accentRed : LightThemeColors.accentRed;

  @override
  Color get accentGreenColor =>
      _isDarkTheme ? DarkThemeColors.accentGreen : LightThemeColors.accentGreen;

  @override
  Color get accentYellowColor => _isDarkTheme
      ? DarkThemeColors.accentYellow
      : LightThemeColors.accentYellow;

  @override
  Color get base01Color =>
      _isDarkTheme ? DarkThemeColors.base01 : LightThemeColors.base01;

  @override
  Color get base02Color =>
      _isDarkTheme ? DarkThemeColors.base02 : LightThemeColors.base02;

  @override
  Color get base03Color =>
      _isDarkTheme ? DarkThemeColors.base03 : LightThemeColors.base03;

  @override
  Color get base04Color =>
      _isDarkTheme ? DarkThemeColors.base04 : LightThemeColors.base04;

  @override
  Color get base05Color =>
      _isDarkTheme ? DarkThemeColors.base05 : LightThemeColors.base05;

  @override
  Color get base06Color =>
      _isDarkTheme ? DarkThemeColors.base06 : LightThemeColors.base06;

  @override
  Color get base07Color =>
      _isDarkTheme ? DarkThemeColors.base07 : LightThemeColors.base07;

  @override
  Color get base08Color =>
      _isDarkTheme ? DarkThemeColors.base08 : LightThemeColors.base08;

  @override
  TextStyle get caption2 => TextStyles.caption2;

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

  @override
  void updateTheme({@required Brightness brightness}) =>
      _isDarkTheme = brightness == Brightness.dark;
}
