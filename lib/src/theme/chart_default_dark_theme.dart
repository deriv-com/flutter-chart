import 'package:deriv_chart/src/theme/text_styles.dart';
import 'package:flutter/material.dart';

import 'chart_default_theme.dart';
import 'colors.dart';

/// An implementation of [ChartDefaultTheme] which provides access to
/// dark theme-related colors and styles for the chart package.
class ChartDefaultDarkTheme extends ChartDefaultTheme {
  @override
  Color get accentRedColor => DarkThemeColors.accentRed;

  @override
  Color get accentGreenColor => DarkThemeColors.accentGreen;

  @override
  Color get accentYellowColor => DarkThemeColors.accentYellow;

  @override
  Color get base01Color => DarkThemeColors.base01;

  @override
  Color get base02Color => DarkThemeColors.base02;

  @override
  Color get base03Color => DarkThemeColors.base03;

  @override
  Color get base04Color => DarkThemeColors.base04;

  @override
  Color get base05Color => DarkThemeColors.base05;

  @override
  Color get base06Color => DarkThemeColors.base06;

  @override
  Color get base07Color => DarkThemeColors.base07;

  @override
  Color get base08Color => DarkThemeColors.base08;

  @override
  TextStyle get overLine => TextStyles.overLine;
}
