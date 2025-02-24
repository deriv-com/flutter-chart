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
  //--------------------------------------------------------------------------
  // Background colors for light and dark modes.
  //--------------------------------------------------------------------------
  static const Color backgroundDynamicLight = Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color backgroundDynamicDark = Color(0xFF181C25); // Hex: #181C25

  //--------------------------------------------------------------------------
  // Default axis theme colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color axisGridDefaultLight =
      Color(0x0A181C25); // Hex: #181C25 with 4% opacity
  static const Color axisGridDefaultDark =
      Color(0x0AFFFFFF); // Hex: #FFFFFF with 4% opacity
  static const Color axisTextDefaultLight =
      Color(0x3D181C25); // Hex: #181C25 with 24% opacity
  static const Color axisTextDefaultDark =
      Color(0x3DFFFFFF); // Hex: #FFFFFF with 24% opacity

  //--------------------------------------------------------------------------
  // Area default theme colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color areaDefaultLineLight = Color(0xFF181C25); // Hex: #181C25
  static const Color areaDefaultLineDark = Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color areaDefaultGradientStartLight =
      Color(0x29181C25); // Hex: #181C25 with 16% opacity
  static const Color areaDefaultGradientStartDark =
      Color(0x29FFFFFF); // Hex: #FFFFFF with 16% opacity
  static const Color areaDefaultGradientEndLight =
      Color(0x00181C25); // Hex: #181C25 with 0% opacity
  static const Color areaDefaultGradientEndDark =
      Color(0x00FFFFFF); // Hex: #FFFFFF with 0% opacity

  //--------------------------------------------------------------------------
  // Area Deriv theme colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color areaDerivLine = Color(0xFFFF444F); // Hex: #FF444F
  static const Color areaDerivGradientStart =
      Color(0x29FF444F); // Hex: #FF444F with 16% opacity
  static const Color areaDerivGradientEnd =
      Color(0x00FF444F); // Hex: #FF444F with 0% opacity

  //--------------------------------------------------------------------------
  // Area Champion theme colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color areaChampionLine = Color(0xFF00D0FF); // Hex: #00D0FF
  static const Color areaChampionGradientStart =
      Color(0x2900D0FF); // Hex: #00D0FF with 16% opacity
  static const Color areaChampionGradientEnd =
      Color(0x0000D0FF); // Hex: #00D0FF with 0% opacity

  //--------------------------------------------------------------------------
  // Candle Bullish theme colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color candleBullishBodyDefault =
      Color(0xFF00C390); // Hex: #00C390
  static const Color candleBullishBodyColorBlind =
      Color(0xFF2C9AFF); // Hex: #2C9AFF
  static const Color candleBullishWickDefault =
      Color(0xFF00AE7A); // Hex: #00AE7A
  static const Color candleBullishWickColorBlind =
      Color(0xFF0777C4); // Hex: #0777C4

  //--------------------------------------------------------------------------
  // Candle Bearish theme colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color candleBearishBodyDefault =
      Color(0xFFDE0040); // Hex: #DE0040
  static const Color candleBearishBodyColorBlind =
      Color(0xFFF7C60B); // Hex: #F7C60B
  static const Color candleBearishWickDefault =
      Color(0xFFC40025); // Hex: #C40025
  static const Color candleBearishWickColorBlind =
      Color(0xFFBD9808); // Hex: #BD9808

  //--------------------------------------------------------------------------
  // Current spot default colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color currentSpotDefaultContainerLight =
      Color(0xFF181C25); // Hex: #181C25
  static const Color currentSpotDefaultContainerDark =
      Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color currentSpotDefaultLabelLight =
      Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color currentSpotDefaultLabelDark =
      Color(0xFF181C25); // Hex: #181C25

  //--------------------------------------------------------------------------
  // Current spot Deriv colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color currentSpotDerivContainer =
      Color(0xFFFF444F); // Hex: #FF444F
  static const Color currentSpotDerivLabel = Color(0xFFFFFFFF); // Hex: #FFFFFF

  //--------------------------------------------------------------------------
  // Current spot Champion colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color currentSpotChampionContainer =
      Color(0xFF00D0FF); // Hex: #00D0FF
  static const Color currentSpotChampionLabel =
      Color(0xFF00375C); // Hex: #00375C

  //--------------------------------------------------------------------------
  // Crosshair colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color crosshairGridLight =
      Color(0x3D181C25); // Hex: #181C25 with 24% opacity
  static const Color crosshairGridDark =
      Color(0x3DFFFFFF); // Hex: #FFFFFF with 24% opacity
  static const Color crosshairTextLight = Color(0xFF181C25); // Hex: #181C25
  static const Color crosshairTextDark = Color(0xFFFFFFFF); // Hex: #FFFFFF

  //--------------------------------------------------------------------------
  // Getters for background color based on mode setting.
  //--------------------------------------------------------------------------
  static Color getBackgroundColor(ChartMode mode) {
    return mode == ChartMode.dark
        ? backgroundDynamicDark
        : backgroundDynamicLight;
  }

  //--------------------------------------------------------------------------
  // Getters for line color properties based on variant and accessibility.
  //--------------------------------------------------------------------------
  // static Color getLineColor(
  //   ChartVariant variant, {
  //   ChartAccessibility accessibility = ChartAccessibility.normal,
  // }) {
  //   switch (variant) {
  //     case ChartVariant.defaultTheme:
  //       return accessibility == ChartAccessibility.colorblind
  //           ? defaultLineColorBlind
  //           : defaultLine;
  //     case ChartVariant.deriv:
  //       return accessibility == ChartAccessibility.colorblind
  //           ? derivLineColorBlind
  //           : derivLine;
  //     case ChartVariant.champion:
  //       return accessibility == ChartAccessibility.colorblind
  //           ? championLineColorBlind
  //           : championLine;
  //   }
  // }

  //--------------------------------------------------------------------------
  // Getters for text colour based on variant and accessibility.
  //--------------------------------------------------------------------------
  // static Color getTextColor(
  //   ChartVariant variant, {
  //   ChartAccessibility accessibility = ChartAccessibility.normal,
  // }) {
  //   switch (variant) {
  //     case ChartVariant.defaultTheme:
  //       return accessibility == ChartAccessibility.colorblind
  //           ? defaultTextColorBlind
  //           : defaultText;
  //     case ChartVariant.deriv:
  //       return accessibility == ChartAccessibility.colorblind
  //           ? derivTextColorBlind
  //           : derivText;
  //     case ChartVariant.champion:
  //       return accessibility == ChartAccessibility.colorblind
  //           ? championTextColorBlind
  //           : championText;
  //   }
  // }

  //--------------------------------------------------------------------------
  // Getters for grid colour based on variant and accessibility.
  //--------------------------------------------------------------------------
  // static Color getGridColor(
  //   ChartVariant variant, {
  //   ChartAccessibility accessibility = ChartAccessibility.normal,
  //   ChartMode mode = ChartMode.light,
  // }) {
  //   switch (variant) {
  //     case ChartVariant.defaultTheme:
  //       if (accessibility == ChartAccessibility.colorblind) {
  //         return defaultGridColorBlind;
  //       }
  //       return mode == ChartMode.dark
  //           ? axisGridDefaultDark
  //           : axisGridDefaultLight;
  //     case ChartVariant.deriv:
  //       return accessibility == ChartAccessibility.colorblind
  //           ? derivGridColorBlind
  //           : derivGrid;
  //     case ChartVariant.champion:
  //       return accessibility == ChartAccessibility.colorblind
  //           ? championGridColorBlind
  //           : championGrid;
  //   }
  // }

  //--------------------------------------------------------------------------
  // Getter for bullish candle colors based on accessibility.
  //--------------------------------------------------------------------------
  static ({Color body, Color wick}) getBullishCandleColors({
    ChartAccessibility accessibility = ChartAccessibility.normal,
  }) {
    return (
      body: accessibility == ChartAccessibility.colorblind
          ? candleBullishBodyColorBlind
          : candleBullishBodyDefault,
      wick: accessibility == ChartAccessibility.colorblind
          ? candleBullishWickColorBlind
          : candleBullishWickDefault,
    );
  }

  //--------------------------------------------------------------------------
  // Getter for bearish candle colors based on accessibility.
  //--------------------------------------------------------------------------
  static ({Color body, Color wick}) getBearishCandleColors({
    ChartAccessibility accessibility = ChartAccessibility.normal,
  }) {
    return (
      body: accessibility == ChartAccessibility.colorblind
          ? candleBearishBodyColorBlind
          : candleBearishBodyDefault,
      wick: accessibility == ChartAccessibility.colorblind
          ? candleBearishWickColorBlind
          : candleBearishWickDefault,
    );
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
  // Utility – Apply an opacity value to a given color.
  //
  // Value for opacity should be between 0.0 (transparent) and 1.0 (opaque).
  //--------------------------------------------------------------------------
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  //--------------------------------------------------------------------------
  // Getter for area colors based on variant and mode.
  //--------------------------------------------------------------------------
  static ({Color line, Color gradientStart, Color gradientEnd}) getAreaColors({
    ChartVariant variant = ChartVariant.defaultTheme,
    ChartMode mode = ChartMode.light,
  }) {
    switch (variant) {
      case ChartVariant.defaultTheme:
        return (
          line: mode == ChartMode.dark
              ? areaDefaultLineDark
              : areaDefaultLineLight,
          gradientStart: mode == ChartMode.dark
              ? areaDefaultGradientStartDark
              : areaDefaultGradientStartLight,
          gradientEnd: mode == ChartMode.dark
              ? areaDefaultGradientEndDark
              : areaDefaultGradientEndLight,
        );
      case ChartVariant.deriv:
        return (
          line: areaDerivLine,
          gradientStart: areaDerivGradientStart,
          gradientEnd: areaDerivGradientEnd,
        );
      case ChartVariant.champion:
        return (
          line: areaChampionLine,
          gradientStart: areaChampionGradientStart,
          gradientEnd: areaChampionGradientEnd,
        );
    }
  }

  //--------------------------------------------------------------------------
  // Getter for current spot colors based on variant and mode.
  //--------------------------------------------------------------------------
  static ({Color container, Color label}) getCurrentSpotColors({
    ChartVariant variant = ChartVariant.defaultTheme,
    ChartMode mode = ChartMode.light,
  }) {
    switch (variant) {
      case ChartVariant.defaultTheme:
        return (
          container: mode == ChartMode.dark
              ? currentSpotDefaultContainerDark
              : currentSpotDefaultContainerLight,
          label: mode == ChartMode.dark
              ? currentSpotDefaultLabelDark
              : currentSpotDefaultLabelLight,
        );
      case ChartVariant.deriv:
        return (
          container: currentSpotDerivContainer,
          label: currentSpotDerivLabel,
        );
      case ChartVariant.champion:
        return (
          container: currentSpotChampionContainer,
          label: currentSpotChampionLabel,
        );
    }
  }

  //--------------------------------------------------------------------------
  // Getter for crosshair colors based on mode.
  //--------------------------------------------------------------------------
  static ({Color grid, Color text}) getCrosshairColors({
    ChartMode mode = ChartMode.light,
  }) {
    return (
      grid: mode == ChartMode.dark ? crosshairGridDark : crosshairGridLight,
      text: mode == ChartMode.dark ? crosshairTextDark : crosshairTextLight,
    );
  }
}
