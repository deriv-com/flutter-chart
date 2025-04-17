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
  Color get backgroundColor => DefaultDarkThemeColors.backgroundDynamicHighest;

  @override
  Color get areaLineColor => DefaultDarkThemeColors.areaLineColor;

  @override
  Color get areaGradientStart => DefaultDarkThemeColors.areaGradientStart;

  @override
  Color get areaGradientEnd => DefaultDarkThemeColors.areaGradientEnd;

  @override
  Color get gridLineColor => DefaultDarkThemeColors.gridLineColor;

  @override
  Color get currentSpotContainerColor =>
      DefaultDarkThemeColors.currentSpotContainerColor;

  @override
  Color get currentSpotTextColor => DefaultDarkThemeColors.currentSpotTextColor;

  @override
  Color get currentSpotLineColor => DefaultDarkThemeColors.currentSpotLineColor;

  @override
  Color get crosshairInformationBoxContainerGlassColor =>
      DefaultDarkThemeColors.crosshairInformationBoxContainerGlassColor;

  @override
  Color get crosshairInformationBoxContainerNormalColor =>
      DefaultDarkThemeColors.crosshairInformationBoxContainerNormalColor;

  @override
  Color get crosshairInformationBoxTextDefault =>
      DefaultDarkThemeColors.crosshairInformationBoxTextDefault;

  @override
  Color get crosshairInformationBoxTextLoss =>
      DefaultDarkThemeColors.crosshairInformationBoxTextLoss;

  @override
  Color get crosshairInformationBoxTextProfit =>
      DefaultDarkThemeColors.crosshairInformationBoxTextProfit;

  @override
  Color get crosshairInformationBoxTextStatic =>
      DefaultDarkThemeColors.crosshairInformationBoxTextStatic;

  @override
  Color get crosshairInformationBoxTextSubtle =>
      DefaultDarkThemeColors.crosshairInformationBoxTextSubtle;

  @override
  Color get crosshairLineDesktopColor =>
      DefaultDarkThemeColors.crosshairLineDesktopColor;

  @override
  Color get crosshairLineResponsiveLowerLineGradientEnd =>
      DefaultDarkThemeColors.crosshairLineResponsiveLowerLineGradientEnd;

  @override
  Color get crosshairLineResponsiveLowerLineGradientStart =>
      DefaultDarkThemeColors.crosshairLineResponsiveLowerLineGradientStart;

  @override
  Color get crosshairLineResponsiveUpperLineGradientEnd =>
      DefaultDarkThemeColors.crosshairLineResponsiveUpperLineGradientEnd;

  @override
  Color get crosshairLineResponsiveUpperLineGradientStart =>
      DefaultDarkThemeColors.crosshairLineResponsiveUpperLineGradientStart;

  @override
  Color get currentSpotDotColor => DefaultDarkThemeColors.currentSpotDotColor;

  @override
  Color get currentSpotDotEffect => DefaultDarkThemeColors.currentSpotDotEffect;

  @override
  Color get gridTextColor => DefaultDarkThemeColors.gridTextColor;

  @override
  GridStyle get gridStyle => GridStyle(
        gridLineColor: gridLineColor,
        xLabelStyle: textStyle(textStyle: gridTextStyle, color: gridTextColor),
        yLabelStyle: textStyle(textStyle: gridTextStyle, color: gridTextColor),
      );

  @override
  LineStyle get areaStyle => LineStyle(
        color: areaLineColor,
        hasArea: true,
        areaGradientColors: (
          start: areaGradientStart,
          end: areaGradientEnd,
        ),
        thickness: areaLineThickness,
      );

  @override
  HorizontalBarrierStyle get currentSpotStyle => HorizontalBarrierStyle(
      color: currentSpotContainerColor,
      textStyle: textStyle(
          textStyle: currentSpotTextStyle, color: currentSpotTextColor),
      isDashed: false,
      labelShapeBackgroundColor: currentSpotContainerColor,
      lineColor: currentSpotLineColor,
      blinkingDotColor: currentSpotDotColor);

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
