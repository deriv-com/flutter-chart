import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_chart/src/theme/text_styles.dart';
import 'package:flutter/material.dart';

import 'chart_default_theme.dart';
import 'colors.dart';

/// An implementation of [ChartDefaultTheme] which provides access to
/// dark theme-related colors and styles for the chart package.
class ChartDefaultDarkTheme extends ChartDefaultTheme {
  @override
  Color get lineColor => DefaultDarkThemeColors.line;

  @override
  Color get backgroundColor => DefaultDarkThemeColors.backgroundDynamicHighest;

  @override
  Color get textColor => DefaultDarkThemeColors.text;

  @override
  Color get subtitleColor => DefaultDarkThemeColors.subtitle;

  @override
  Color get containerColor => DefaultDarkThemeColors.container;

  @override
  Color get gradientStart => DefaultDarkThemeColors.gradientStart;

  @override
  Color get gradientEnd => DefaultDarkThemeColors.gradientEnd;

  @override
  Color get dotColor => DefaultDarkThemeColors.dot;

  @override
  Color get effectColor => DefaultDarkThemeColors.effect;

  @override
  Color get subtitle2Color => DefaultDarkThemeColors.subtitle2;

  @override
  Color get desktopColor => DefaultDarkThemeColors.desktop;

  @override
  LineStyle get areaLineStyle => const LineStyle(
        color: DefaultDarkThemeColors.areaDefaultLine,
        hasArea: true,
        areaGradientColors: (
          start: DefaultDarkThemeColors.areaDefaultGradientStart,
          end: DefaultDarkThemeColors.areaDefaultGradientEnd,
        ),
      );

  @override
  GridStyle get axisGridStyle => GridStyle(
        gridLineColor: DefaultDarkThemeColors.axisGridDefault,
        xLabelStyle: textStyle(
            textStyle: TextStyles.axisLabel,
            color: DefaultDarkThemeColors.axisTextDefault),
        yLabelStyle: textStyle(
            textStyle: TextStyles.axisLabel,
            color: DefaultDarkThemeColors.axisTextDefault),
      );

  @override
  HorizontalBarrierStyle get currentSpotStyle => HorizontalBarrierStyle(
      color: DefaultDarkThemeColors.currentSpotDefaultContainer,
      textStyle: textStyle(
          textStyle: currentSpotLabelText,
          color: DefaultDarkThemeColors.currentSpotDefaultLabel),
      isDashed: false);

  @override
  LineStyle get lineStyle =>
      const LineStyle(color: DefaultDarkThemeColors.line);

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
  Color get hoverColor => LightThemeColors.hover;

  @override
  TextStyle get overLine => TextStyles.overLine;
}
