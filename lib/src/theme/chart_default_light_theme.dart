import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/theme/text_styles.dart';
import 'package:flutter/material.dart';

import 'chart_default_theme.dart';
import 'colors.dart';

/// An implementation of [ChartDefaultTheme] which provides access to
/// light theme-related colors and styles for the chart package.
class ChartDefaultLightTheme extends ChartDefaultTheme {
  @override
  Color get backgroundDynamic => ChartColors.getBackgroundColor();

  @override
  GridStyle get axisGridDefaultStyle => GridStyle(
        gridLineColor: ChartColors.getAxisColors().grid,
        xLabelStyle: textStyle(
            textStyle: TextStyles.bodyXsRegular,
            color: ChartColors.getAxisColors().text),
        yLabelStyle: textStyle(
            textStyle: TextStyles.bodyXsRegular,
            color: ChartColors.getAxisColors().text),
        xLabelsAreaHeight: 24, // TODO: Verify whether this should be 8 or 24.
      );

  @override
  LineStyle get areaDefaultLineStyle => LineStyle(
        color: ChartColors.getAreaColors().line,
        thickness: 1,
        hasArea: true,
        markerRadius: 4,
        areaGradientColors: (
          start: ChartColors.getAreaColors().gradientStart,
          end: ChartColors.getAreaColors().gradientEnd
        ),
      );

  @override
  LineStyle get areaDerivLineStyle => LineStyle(
        color: ChartColors.getAreaColors(variant: ChartVariant.deriv).line,
        thickness: 1,
        hasArea: true,
        markerRadius: 4,
        areaGradientColors: (
          start: ChartColors.getAreaColors(variant: ChartVariant.deriv)
              .gradientStart,
          end:
              ChartColors.getAreaColors(variant: ChartVariant.deriv).gradientEnd
        ),
      );

  @override
  LineStyle get areaChampionLineStyle => LineStyle(
        color: ChartColors.getAreaColors(variant: ChartVariant.champion).line,
        thickness: 1,
        hasArea: true,
        markerRadius: 4,
        areaGradientColors: (
          start: ChartColors.getAreaColors(variant: ChartVariant.champion)
              .gradientStart,
          end: ChartColors.getAreaColors(variant: ChartVariant.champion)
              .gradientEnd
        ),
      );

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
