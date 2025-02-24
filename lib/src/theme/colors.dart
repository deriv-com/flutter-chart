// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

/// Deriv branding colors, these colors should not be changed. It can be called
/// as [BrandColors.coral].
class BrandColors {
  static const Color coral = Color(0xFFFF444F);
  static const Color greenish = Color(0xFF85ACB0);
  static const Color orange = Color(0xFFFF6444);
}

/// These colors suits the dark theme of Deriv.
class DarkThemeColors {
  static const Color base01 = Color(0xFFFFFFFF);
  static const Color base02 = Color(0xFFEAECED);
  static const Color base03 = Color(0xFFC2C2C2);
  static const Color base04 = Color(0xFF6E6E6E);
  static const Color base05 = Color(0xFF3E3E3E);
  static const Color base06 = Color(0xFF323738);
  static const Color base07 = Color(0xFF151717);
  static const Color base08 = Color(0xFF0E0E0E);
  static const Color accentGreen = Color(0xFF00A79E);
  static const Color accentYellow = Color(0xFFFFAD3A);
  static const Color accentRed = Color(0xFFCC2E3D);
  static const Color hover = Color(0xFF242828);
}

/// These colors suits the light theme of Deriv.
// TODO(Ramin): replace values based on light theme when available
class LightThemeColors {
  static const Color base01 = Color(0xFF0E0E0E);
  static const Color base02 = Color(0xFF151717);
  static const Color base03 = Color(0xFF323738);
  static const Color base04 = Color(0xFF3E3E3E);
  static const Color base05 = Color(0xFF6E6E6E);
  static const Color base06 = Color(0xFFC2C2C2);
  static const Color base07 = Color(0xFFEAECED);
  static const Color base08 = Color(0xFFFFFFFF);
  static const Color accentGreen = Color(0xFF00A79E);
  static const Color accentYellow = Color(0xFFFFAD3A);
  static const Color accentRed = Color(0xFFCC2E3D);
  static const Color hover = Color(0xFF242828);
}

/// Chart theme variants – these typically control the “look and feel”
/// of most elements such as lines, grid and text.
enum ChartVariant {
  defaultTheme,
  deriv,
  champion,
}

/// Chart display modes – use this to swap backgrounds (or other tokens)
/// for a light/dark design.
enum ChartMode {
  light,
  dark,
}

/// Accessibility options – for example, a “colorblind” mode.
enum ChartAccessibility {
  normal,
  colorblind,
}

/// ChartColors groups all token definitions – standard colors, candle colors,
/// and any special cases for accessibility. You can further extend these definitions
/// with additional tokens as needed.
class ChartColors {
  // Background colors for light and dark modes.
  static const Color backgroundDynamicLight = Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color backgroundDynamicDark = Color(0xFF181C25); // Hex: #181C25

  //--------------------------------------------------------------------------
  // Default theme colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color defaultLine = Color(0xFF181C25); // Hex: #181C25
  static const Color defaultText = Color(0xFF181C25); // Hex: #181C25

  //--------------------------------------------------------------------------
  // Current spot default colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color currentSpotContainerDefaultLight = Color(0xFF181C25); // Hex: #181C25
  static const Color currentSpotContainerDefaultDark = Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color currentSpotLabelDefaultLight = Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color currentSpotLabelDefaultDark = Color(0xFF181C25); // Hex: #181C25

  //--------------------------------------------------------------------------
  // Crosshair colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color crosshairGridLight = Color(0x3D181C25); // Hex: #181C25 with 24% opacity
  static const Color crosshairGridDark = Color(0x3DFFFFFF); // Hex: #FFFFFF with 24% opacity
  static const Color crosshairTextLight = Color(0xFF181C25); // Hex: #181C25
  static const Color crosshairTextDark = Color(0xFFFFFFFF); // Hex: #FFFFFF

  //--------------------------------------------------------------------------
  // Default axis theme colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color axisTextDefaultLight =
      Color(0x3D181C25); // Hex: #181C25 with 24% opacity
  static const Color axisTextDefaultDark =
      Color(0x3DFFFFFF); // Hex: #FFFFFF with 24% opacity
  static const Color axisGridDefaultLight =
      Color(0x0A181C25); // Hex: #181C25 with 4% opacity
  static const Color axisGridDefaultDark =
      Color(0x0AFFFFFF); // Hex: #FFFFFF with 4% opacity

  //--------------------------------------------------------------------------
  // Area default theme colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color areaLineLight = Color(0xFF181C25); // Hex: #181C25
  static const Color areaLineDark = Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color areaGradientStartLight =
      Color(0x29181C25); // Hex: #181C25 with 16% opacity
  static const Color areaGradientStartDark =
      Color(0x29FFFFFF); // Hex: #FFFFFF with 16% opacity
  static const Color areaGradientEndLight =
      Color(0x00181C25); // Hex: #181C25 with 0% opacity
  static const Color areaGradientEndDark =
      Color(0x00FFFFFF); // Hex: #FFFFFF with 0% opacity

//--------------------------------------------------------------------------
// Deriv colors
//--------------------------------------------------------------------------
  // Area colors
  static const Color derivAreaLine = Color(0xFFFF444F); // Hex: #FF444F
  
  // Current spot colors
  static const Color currentSpotContainerDeriv = Color(0xFFFF444F); // Hex: #FF444F
  static const Color currentSpotLabelDeriv = Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color derivAreaGradientStart =
      Color(0x29FF444F); // Hex: #FF444F with 16% opacity
  static const Color derivAreaGradientEnd =
      Color(0x00FF444F); // Hex: #FF444F with 0% opacity

//--------------------------------------------------------------------------
// Champion colors
//--------------------------------------------------------------------------
  // Area colors
  static const Color championAreaLine = Color(0xFF00D0FF); // Hex: #00D0FF

  // Current spot colors
  static const Color currentSpotContainerChampion = Color(0xFF00D0FF); // Hex: #00D0FF
  static const Color currentSpotLabelChampion = Color(0xFF00375C); // Hex: #00375C
  static const Color championAreaGradientStart =
      Color(0x2900D0FF); // Hex: #00D0FF with 16% opacity
  static const Color championAreaGradientEnd =
      Color(0x0000D0FF); // Hex: #00D0FF with 0% opacity

  // Alternative colors for colorblind mode for default theme.
  // You might need to adjust these to ensure adequate contrast and separation.
  static const Color defaultLineColorBlind = Color(0xFF2C3E50); // Hex: #2C3E50
  static const Color defaultTextColorBlind = Color(0xFF2C3E50); // Hex: #2C3E50
  static const Color defaultGridColorBlind = Color(0xFF2C3E50); // Hex: #2C3E50

  //--------------------------------------------------------------------------
  // Deriv theme colors. to be deleted
  //--------------------------------------------------------------------------
  // Base colors
  static const Color derivLine = Color(0xFFFF444F); // Hex: #FF444F
  static const Color derivText = Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color derivGrid = Color(0xFFFF444F); // Hex: #FF444F

  // Alternative colors for colorblind mode for deriv theme.
  static const Color derivLineColorBlind = Color(0xFFE74C3C); // Hex: #E74C3C
  static const Color derivTextColorBlind = Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color derivGridColorBlind = Color(0xFFE74C3C); // Hex: #E74C3C

  //--------------------------------------------------------------------------
  // Champion theme colors. to be deleted
  //--------------------------------------------------------------------------
  // Base colors
  static const Color championLine = Color(0xFF00D0FF); // Hex: #00D0FF
  static const Color championText = Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color championGrid = Color(0xFF00D0FF); // Hex: #00D0FF

  // Alternative colors for colorblind mode for champion theme.
  static const Color championLineColorBlind = Color(0xFF3498DB); // Hex: #3498DB
  static const Color championTextColorBlind = Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color championGridColorBlind = Color(0xFF3498DB); // Hex: #3498DB

  //--------------------------------------------------------------------------
  // Candle colors (commonly used on chart candlesticks).
  //--------------------------------------------------------------------------
  // Standard candle colors.
  static const Color candleBullishBodyDefault = Color(0xFF00C390); // Hex: #00C390
  static const Color candleBullishWickDefault = Color(0xFF00AE7A); // Hex: #00AE7A
  static const Color candleBearishBodyDefault = Color(0xFFDE0040); // Hex: #DE0040
  static const Color candleBearishWickDefault = Color(0xFFC40025); // Hex: #C40025

  // Alternative candle colors for colorblind mode.
  static const Color candleBullishBodyColorBlind = Color(0xFF2C9AFF); // Hex: #2C9AFF
  static const Color candleBullishWickColorBlind = Color(0xFF0777C4); // Hex: #0777C4
  static const Color candleBearishBodyColorBlind = Color(0xFFF7C60B); // Hex: #F7C60B
  static const Color candleBearishWickColorBlind = Color(0xFFBD9808); // Hex: #BD9808

  //--------------------------------------------------------------------------
  // Getters for background colour based on our mode setting.
  //--------------------------------------------------------------------------
  static Color getBackgroundColor(ChartMode mode) {
    return mode == ChartMode.dark
        ? backgroundDynamicDark
        : backgroundDynamicLight;
  }

  //--------------------------------------------------------------------------
  // Getters for line colour properties based on variant and accessibility.
  //--------------------------------------------------------------------------
  static Color getLineColor(
    ChartVariant variant, {
    ChartAccessibility accessibility = ChartAccessibility.normal,
  }) {
    switch (variant) {
      case ChartVariant.defaultTheme:
        return accessibility == ChartAccessibility.colorblind
            ? defaultLineColorBlind
            : defaultLine;
      case ChartVariant.deriv:
        return accessibility == ChartAccessibility.colorblind
            ? derivLineColorBlind
            : derivLine;
      case ChartVariant.champion:
        return accessibility == ChartAccessibility.colorblind
            ? championLineColorBlind
            : championLine;
    }
  }

  //--------------------------------------------------------------------------
  // Getters for text colour based on variant and accessibility.
  //--------------------------------------------------------------------------
  static Color getTextColor(
    ChartVariant variant, {
    ChartAccessibility accessibility = ChartAccessibility.normal,
  }) {
    switch (variant) {
      case ChartVariant.defaultTheme:
        return accessibility == ChartAccessibility.colorblind
            ? defaultTextColorBlind
            : defaultText;
      case ChartVariant.deriv:
        return accessibility == ChartAccessibility.colorblind
            ? derivTextColorBlind
            : derivText;
      case ChartVariant.champion:
        return accessibility == ChartAccessibility.colorblind
            ? championTextColorBlind
            : championText;
    }
  }

  //--------------------------------------------------------------------------
  // Getters for grid colour based on variant and accessibility.
  //--------------------------------------------------------------------------
  static Color getGridColor(
    ChartVariant variant, {
    ChartAccessibility accessibility = ChartAccessibility.normal,
    ChartMode mode = ChartMode.light,
  }) {
    switch (variant) {
      case ChartVariant.defaultTheme:
        if (accessibility == ChartAccessibility.colorblind) {
          return defaultGridColorBlind;
        }
        return mode == ChartMode.dark
            ? axisGridDefaultDark
            : axisGridDefaultLight;
      case ChartVariant.deriv:
        return accessibility == ChartAccessibility.colorblind
            ? derivGridColorBlind
            : derivGrid;
      case ChartVariant.champion:
        return accessibility == ChartAccessibility.colorblind
            ? championGridColorBlind
            : championGrid;
    }
  }

  //--------------------------------------------------------------------------
  // Getters for candle colors based on accessibility mode.
  //--------------------------------------------------------------------------
  static Color getCandleBullishBodyColor({
    ChartAccessibility accessibility = ChartAccessibility.normal,
  }) {
    return accessibility == ChartAccessibility.colorblind
        ? candleBullishBodyColorBlind
        : candleBullishBodyDefault;
  }

  static Color getCandleBullishWickColor({
    ChartAccessibility accessibility = ChartAccessibility.normal,
  }) {
    return accessibility == ChartAccessibility.colorblind
        ? candleBullishWickColorBlind
        : candleBullishWickDefault;
  }

  static Color getCandleBearishBodyColor({
    ChartAccessibility accessibility = ChartAccessibility.normal,
  }) {
    return accessibility == ChartAccessibility.colorblind
        ? candleBearishBodyColorBlind
        : candleBearishBodyDefault;
  }

  static Color getCandleBearishWickColor({
    ChartAccessibility accessibility = ChartAccessibility.normal,
  }) {
    return accessibility == ChartAccessibility.colorblind
        ? candleBearishWickColorBlind
        : candleBearishWickDefault;
  }

  //--------------------------------------------------------------------------
  // Getter for axis text color based on mode.
  //--------------------------------------------------------------------------
  static Color getAxisTextColor({
    ChartMode mode = ChartMode.light,
  }) {
    return mode == ChartMode.dark ? axisTextDefaultDark : axisTextDefaultLight;
  }

  //--------------------------------------------------------------------------
  // Utility – Apply an opacity value to a given colour.
  //
  // Value for opacity should be between 0.0 (transparent) and 1.0 (opaque).
  //--------------------------------------------------------------------------
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  //--------------------------------------------------------------------------
  // Getters for area colors based on mode.
  //--------------------------------------------------------------------------
  static Color getAreaLineColor({
    ChartMode mode = ChartMode.light,
  }) {
    return mode == ChartMode.dark ? areaLineDark : areaLineLight;
  }

  static Color getAreaGradientStartColor({
    ChartMode mode = ChartMode.light,
  }) {
    return mode == ChartMode.dark
        ? areaGradientStartDark
        : areaGradientStartLight;
  }

  static Color getAreaGradientEndColor({
    ChartMode mode = ChartMode.light,
  }) {
    return mode == ChartMode.dark ? areaGradientEndDark : areaGradientEndLight;
  }

  //--------------------------------------------------------------------------
  // Getters for deriv area colors.
  //--------------------------------------------------------------------------
  static Color getDerivAreaLineColor() {
    return derivAreaLine;
  }

  //--------------------------------------------------------------------------
  // Getters for deriv current spot colors.
  //--------------------------------------------------------------------------
  static Color getCurrentSpotContainerDerivColor() {
    return currentSpotContainerDeriv;
  }

  static Color getCurrentSpotLabelDerivColor() {
    return currentSpotLabelDeriv;
  }

  static Color getDerivAreaGradientStartColor() {
    return derivAreaGradientStart;
  }

  static Color getDerivAreaGradientEndColor() {
    return derivAreaGradientEnd;
  }

  //--------------------------------------------------------------------------
  // Getters for champion area colors.
  //--------------------------------------------------------------------------
  static Color getChampionAreaLineColor() {
    return championAreaLine;
  }

  //--------------------------------------------------------------------------
  // Getters for champion current spot colors.
  //--------------------------------------------------------------------------
  static Color getCurrentSpotContainerChampionColor() {
    return currentSpotContainerChampion;
  }

  static Color getCurrentSpotLabelChampionColor() {
    return currentSpotLabelChampion;
  }

  static Color getChampionAreaGradientStartColor() {
    return championAreaGradientStart;
  }

  static Color getChampionAreaGradientEndColor() {
    return championAreaGradientEnd;
  }

  //--------------------------------------------------------------------------
  // Getters for current spot colors based on mode.
  //--------------------------------------------------------------------------
  static Color getCurrentSpotContainerDefaultColor({
    ChartMode mode = ChartMode.light,
  }) {
    return mode == ChartMode.dark ? currentSpotContainerDefaultDark : currentSpotContainerDefaultLight;
  }

  static Color getCurrentSpotLabelDefaultColor({
    ChartMode mode = ChartMode.light,
  }) {
    return mode == ChartMode.dark ? currentSpotLabelDefaultDark : currentSpotLabelDefaultLight;
  }

  //--------------------------------------------------------------------------
  // Getters for crosshair colors based on mode.
  //--------------------------------------------------------------------------
  static Color getCrosshairGridColor({
    ChartMode mode = ChartMode.light,
  }) {
    return mode == ChartMode.dark ? crosshairGridDark : crosshairGridLight;
  }

  static Color getCrosshairTextColor({
    ChartMode mode = ChartMode.light,
  }) {
    return mode == ChartMode.dark ? crosshairTextDark : crosshairTextLight;
  }
}
