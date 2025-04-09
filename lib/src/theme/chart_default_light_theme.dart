import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/grid_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_chart/src/theme/text_styles.dart';
import 'package:flutter/material.dart';

import 'chart_default_theme.dart';
import 'colors.dart';

/// An implementation of [ChartDefaultTheme] which provides access to
/// light theme-related colors and styles for the chart package.
class ChartDefaultLightTheme extends ChartDefaultTheme {
  @override
  Color get lineColor => DefaultLightThemeColors.line;

  @override
  Color get backgroundColor => DefaultLightThemeColors.backgroundDynamicHighest;

  @override
  Color get textColor => DefaultLightThemeColors.text;

  @override
  Color get subtitleColor => DefaultLightThemeColors.subtitle;

  @override
  Color get containerColor => DefaultLightThemeColors.container;

  @override
  Color get gradientStart => DefaultLightThemeColors.gradientStart;

  @override
  Color get gradientEnd => DefaultLightThemeColors.gradientEnd;

  @override
  Color get dotColor => DefaultLightThemeColors.dot;

  @override
  Color get subtitle2Color => DefaultLightThemeColors.subtitle2;

  @override
  Color get effectColor => DefaultLightThemeColors.effect;

  @override
  Color get desktopColor => DefaultLightThemeColors.desktop;

  @override
  LineStyle get areaLineStyle => const LineStyle(
        color: DefaultLightThemeColors.areaDefaultLine,
        hasArea: true,
        areaGradientColors: (
          start: DefaultLightThemeColors.areaDefaultGradientStart,
          end: DefaultLightThemeColors.areaDefaultGradientEnd,
        ),
      );

  @override
  GridStyle get axisGridStyle => GridStyle(
        gridLineColor: DefaultLightThemeColors.axisGridDefault,
        xLabelStyle: textStyle(
            textStyle: TextStyles.axisLabel,
            color: DefaultLightThemeColors.axisTextDefault),
        yLabelStyle: textStyle(
            textStyle: TextStyles.axisLabel,
            color: DefaultLightThemeColors.axisTextDefault),
      );

  @override
  HorizontalBarrierStyle get currentSpotStyle => HorizontalBarrierStyle(
        color: DefaultLightThemeColors.currentSpotDefaultContainer,
        textStyle: textStyle(
            textStyle: currentSpotLabelText,
            color: DefaultLightThemeColors.currentSpotDefaultLabel),
        isDashed: false,
      );

  @override
  LineStyle get lineStyle =>
      const LineStyle(color: DefaultLightThemeColors.line);

  @override
  Color get accentRedColor => LightThemeColors.accentRed;

  @override
  Color get accentGreenColor => LightThemeColors.accentGreen;

  @override
  Color get accentYellowColor => LightThemeColors.accentYellow;

  @override
  Color get base01Color => LightThemeColors.base01;

  @override
  Color get base02Color => LightThemeColors.base02;

  @override
  Color get base03Color => LightThemeColors.base03;

  @override
  Color get base04Color => LightThemeColors.base04;

  @override
  Color get base05Color => LightThemeColors.base05;

  @override
  Color get base06Color => LightThemeColors.base06;

  @override
  Color get base07Color => LightThemeColors.base07;

  @override
  Color get base08Color => LightThemeColors.base08;

  @override
  Color get hoverColor => LightThemeColors.hover;

  @override
  TextStyle get overLine => TextStyles.overLine;
}
