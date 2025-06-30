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
  Color get backgroundColor => LightThemeColors.backgroundDynamicHighest;

  @override
  Color get areaLineColor => LightThemeColors.areaLineColor;

  @override
  Color get areaGradientStart => LightThemeColors.areaGradientStart;

  @override
  Color get areaGradientEnd => LightThemeColors.areaGradientEnd;

  @override
  Color get gridLineColor => LightThemeColors.gridLineColor;

  @override
  Color get currentSpotContainerColor =>
      LightThemeColors.currentSpotContainerColor;

  @override
  Color get currentSpotTextColor => LightThemeColors.currentSpotTextColor;

  @override
  Color get currentSpotLineColor => LightThemeColors.currentSpotLineColor;

  @override
  Color get crosshairInformationBoxContainerGlassColor =>
      LightThemeColors.crosshairInformationBoxContainerGlassColor;

  @override
  Color get crosshairInformationBoxContainerNormalColor =>
      LightThemeColors.crosshairInformationBoxContainerNormalColor;

  @override
  Color get crosshairInformationBoxTextDefault =>
      LightThemeColors.crosshairInformationBoxTextDefault;

  @override
  Color get crosshairInformationBoxTextLoss =>
      LightThemeColors.crosshairInformationBoxTextLoss;

  @override
  Color get crosshairInformationBoxTextProfit =>
      LightThemeColors.crosshairInformationBoxTextProfit;

  @override
  Color get crosshairInformationBoxTextStatic =>
      LightThemeColors.crosshairInformationBoxTextStatic;

  @override
  Color get crosshairInformationBoxTextSubtle =>
      LightThemeColors.crosshairInformationBoxTextSubtle;

  @override
  Color get crosshairLineDesktopColor =>
      LightThemeColors.crosshairLineDesktopColor;

  @override
  Color get crosshairLineResponsiveLowerLineGradientEnd =>
      LightThemeColors.crosshairLineResponsiveLowerLineGradientEnd;

  @override
  Color get crosshairLineResponsiveLowerLineGradientStart =>
      LightThemeColors.crosshairLineResponsiveLowerLineGradientStart;

  @override
  Color get crosshairLineResponsiveUpperLineGradientEnd =>
      LightThemeColors.crosshairLineResponsiveUpperLineGradientEnd;

  @override
  Color get crosshairLineResponsiveUpperLineGradientStart =>
      LightThemeColors.crosshairLineResponsiveUpperLineGradientStart;

  @override
  Color get currentSpotDotColor => LightThemeColors.currentSpotDotColor;

  @override
  Color get currentSpotDotEffect => LightThemeColors.currentSpotDotEffect;

  @override
  Color get gridTextColor => LightThemeColors.gridTextColor;

  @override
  GridStyle get gridStyle => GridStyle(
        gridLineColor: gridLineColor,
        xLabelStyle: textStyle(textStyle: gridTextStyle, color: gridTextColor),
        yLabelStyle: textStyle(textStyle: gridTextStyle, color: gridTextColor),
      );

  @override
  LineStyle get lineStyle => LineStyle(
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
  TextStyle get overLine => TextStyles.overLine;

  @override
  Color get floatingMenuContainerGlassColor =>
      LightThemeColors.floatingMenuContainerGlassColor;

  @override
  Color get floatingMenuDragIconColor =>
      LightThemeColors.floatingMenuDragIconColor;

  @override
  Color get lineThicknessDropdownButtonTextColor =>
      LightThemeColors.lineThicknessDropdownButtonTextColor;

  @override
  TextStyle get lineThicknessDropdownButtonTextStyle =>
      TextStyles.lineThicknessDropdownButtonTextStyle;

  @override
  Color get lineThicknessDropdownItemSelectedBackgroundColor =>
      LightThemeColors.lineThicknessDropdownItemSelectedBackgroundColor;

  @override
  Color get lineThicknessDropdownItemSelectedTextColor =>
      LightThemeColors.lineThicknessDropdownItemSelectedTextColor;

  @override
  Color get lineThicknessDropdownItemUnselectedTextColor =>
      LightThemeColors.lineThicknessDropdownItemUnselectedTextColor;

  @override
  Color get lineThicknessDropdownItemSelectedLineColor =>
      LightThemeColors.lineThicknessDropdownItemSelectedLineColor;

  @override
  Color get lineThicknessDropdownItemUnselectedLineColor =>
      LightThemeColors.lineThicknessDropdownItemUnselectedLineColor;

  @override
  TextStyle get lineThicknessDropdownItemTextStyle =>
      TextStyles.lineThicknessDropdownItemTextStyle;

  @override
  Color get base01Color => LegacyLightThemeColors.base01;

  @override
  Color get base03Color => LegacyLightThemeColors.base03;

  @override
  Color get base04Color => LegacyLightThemeColors.base04;

  @override
  Color get base05Color => LegacyLightThemeColors.base05;

  @override
  Color get base07Color => LegacyLightThemeColors.base07;
}
