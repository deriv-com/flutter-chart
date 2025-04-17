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
  Color get backgroundColor => DefaultLightThemeColors.backgroundDynamicHighest;

  @override
  Color get areaLineColor => DefaultLightThemeColors.areaLineColor;

  @override
  Color get areaGradientStart => DefaultLightThemeColors.areaGradientStart;

  @override
  Color get areaGradientEnd => DefaultLightThemeColors.areaGradientEnd;

  @override
  Color get gridLineColor => DefaultLightThemeColors.gridLineColor;

  @override
  Color get currentSpotContainerColor =>
      DefaultLightThemeColors.currentSpotContainerColor;

  @override
  Color get currentSpotTextColor =>
      DefaultLightThemeColors.currentSpotTextColor;

  @override
  Color get currentSpotLineColor =>
      DefaultLightThemeColors.currentSpotLineColor;

  @override
  Color get crosshairInformationBoxContainerGlassColor =>
      DefaultLightThemeColors.crosshairInformationBoxContainerGlassColor;

  @override
  Color get crosshairInformationBoxContainerNormalColor =>
      DefaultLightThemeColors.crosshairInformationBoxContainerNormalColor;

  @override
  Color get crosshairInformationBoxTextDefault =>
      DefaultLightThemeColors.crosshairInformationBoxTextDefault;

  @override
  Color get crosshairInformationBoxTextLoss =>
      DefaultLightThemeColors.crosshairInformationBoxTextLoss;

  @override
  Color get crosshairInformationBoxTextProfit =>
      DefaultLightThemeColors.crosshairInformationBoxTextProfit;

  @override
  Color get crosshairInformationBoxTextStatic =>
      DefaultLightThemeColors.crosshairInformationBoxTextStatic;

  @override
  Color get crosshairInformationBoxTextSubtle =>
      DefaultLightThemeColors.crosshairInformationBoxTextSubtle;

  @override
  Color get crosshairLineDesktopColor =>
      DefaultLightThemeColors.crosshairLineDesktopColor;

  @override
  Color get crosshairLineResponsiveLowerLineGradientEnd =>
      DefaultLightThemeColors.crosshairLineResponsiveLowerLineGradientEnd;

  @override
  Color get crosshairLineResponsiveLowerLineGradientStart =>
      DefaultLightThemeColors.crosshairLineResponsiveLowerLineGradientStart;

  @override
  Color get crosshairLineResponsiveUpperLineGradientEnd =>
      DefaultLightThemeColors.crosshairLineResponsiveUpperLineGradientEnd;

  @override
  Color get crosshairLineResponsiveUpperLineGradientStart =>
      DefaultLightThemeColors.crosshairLineResponsiveUpperLineGradientStart;

  @override
  Color get currentSpotDotColor => DefaultLightThemeColors.currentSpotDotColor;

  @override
  Color get currentSpotDotEffect =>
      DefaultLightThemeColors.currentSpotDotEffect;

  @override
  Color get gridTextColor => DefaultLightThemeColors.gridTextColor;

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
