import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/theme/text_styles.dart';
import 'package:flutter/material.dart';

import 'chart_default_theme.dart';
import 'colors.dart';

/// An implementation of [ChartDefaultTheme] which provides access to
/// dark theme-related colors and styles for the chart package.
class ChartDefaultDarkTheme extends ChartDefaultTheme {
  @override
  Color get backgroundDynamic =>
      ChartColors.getBackgroundColor(mode: ChartMode.dark);

  @override
  GridStyle get axisGridDefaultStyle => GridStyle(
        gridLineColor: ChartColors.getAxisColors(mode: ChartMode.dark).grid,
        xLabelStyle: textStyle(
            textStyle: TextStyles.bodyXsRegular,
            color: ChartColors.getAxisColors(mode: ChartMode.dark).text),
        yLabelStyle: textStyle(
            textStyle: TextStyles.bodyXsRegular,
            color: ChartColors.getAxisColors(mode: ChartMode.dark).text),
        xLabelsAreaHeight: 24, // TODO: Verify whether this should be 8 or 24.
      );

  @override
  LineStyle get areaDefaultLineStyle => LineStyle(
        color: ChartColors.getAreaColors(mode: ChartMode.dark).line,
        thickness: 1,
        hasArea: true,
        markerRadius: 4,
        areaGradientColors: (
          start: ChartColors.getAreaColors(mode: ChartMode.dark).gradientStart,
          end: ChartColors.getAreaColors(mode: ChartMode.dark).gradientEnd
        ),
      );

  @override
  LineStyle get areaDerivLineStyle => LineStyle(
        color: ChartColors.getAreaColors(
                variant: ChartVariant.deriv, mode: ChartMode.dark)
            .line,
        thickness: 1,
        hasArea: true,
        markerRadius: 4,
        areaGradientColors: (
          start: ChartColors.getAreaColors(
                  variant: ChartVariant.deriv, mode: ChartMode.dark)
              .gradientStart,
          end: ChartColors.getAreaColors(
                  variant: ChartVariant.deriv, mode: ChartMode.dark)
              .gradientEnd
        ),
      );

  @override
  LineStyle get areaChampionLineStyle => LineStyle(
        color: ChartColors.getAreaColors(
                variant: ChartVariant.champion, mode: ChartMode.dark)
            .line,
        thickness: 1,
        hasArea: true,
        markerRadius: 4,
        areaGradientColors: (
          start: ChartColors.getAreaColors(
                  variant: ChartVariant.champion, mode: ChartMode.dark)
              .gradientStart,
          end: ChartColors.getAreaColors(
                  variant: ChartVariant.champion, mode: ChartMode.dark)
              .gradientEnd
        ),
      );

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
