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

/// Chart theme variants – these typically control the "look and feel"
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

/// Accessibility options – for example, a "colorblind" mode.
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
  static const Color _backgroundDynamicLight =
      Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color _backgroundDynamicDark = Color(0xFF181C25); // Hex: #181C25

  //--------------------------------------------------------------------------
  // Default axis theme colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color _axisGridDefaultLight =
      Color(0x0A181C25); // Hex: #181C25 with 4% opacity
  static const Color _axisGridDefaultDark =
      Color(0x0AFFFFFF); // Hex: #FFFFFF with 4% opacity
  static const Color _axisTextDefaultLight =
      Color(0x3D181C25); // Hex: #181C25 with 24% opacity
  static const Color _axisTextDefaultDark =
      Color(0x3DFFFFFF); // Hex: #FFFFFF with 24% opacity

  //--------------------------------------------------------------------------
  // Area default theme colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color _areaDefaultLineLight = Color(0xFF181C25); // Hex: #181C25
  static const Color _areaDefaultLineDark = Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color _areaDefaultGradientStartLight =
      Color(0x29181C25); // Hex: #181C25 with 16% opacity
  static const Color _areaDefaultGradientStartDark =
      Color(0x29FFFFFF); // Hex: #FFFFFF with 16% opacity
  static const Color _areaDefaultGradientEndLight =
      Color(0x00181C25); // Hex: #181C25 with 0% opacity
  static const Color _areaDefaultGradientEndDark =
      Color(0x00FFFFFF); // Hex: #FFFFFF with 0% opacity

  //--------------------------------------------------------------------------
  // Area Deriv theme colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color _areaDerivLine = Color(0xFFFF444F); // Hex: #FF444F
  static const Color _areaDerivGradientStart =
      Color(0x29FF444F); // Hex: #FF444F with 16% opacity
  static const Color _areaDerivGradientEnd =
      Color(0x00FF444F); // Hex: #FF444F with 0% opacity

  //--------------------------------------------------------------------------
  // Area Champion theme colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color _areaChampionLine = Color(0xFF00D0FF); // Hex: #00D0FF
  static const Color _areaChampionGradientStart =
      Color(0x2900D0FF); // Hex: #00D0FF with 16% opacity
  static const Color _areaChampionGradientEnd =
      Color(0x0000D0FF); // Hex: #00D0FF with 0% opacity

  //--------------------------------------------------------------------------
  // Candle Bullish theme colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color _candleBullishBodyDefault =
      Color(0xFF00C390); // Hex: #00C390
  static const Color _candleBullishBodyColorBlind =
      Color(0xFF2C9AFF); // Hex: #2C9AFF
  static const Color _candleBullishWickDefault =
      Color(0xFF00AE7A); // Hex: #00AE7A
  static const Color _candleBullishWickColorBlind =
      Color(0xFF0777C4); // Hex: #0777C4

  //--------------------------------------------------------------------------
  // Candle Bearish theme colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color _candleBearishBodyDefault =
      Color(0xFFDE0040); // Hex: #DE0040
  static const Color _candleBearishBodyColorBlind =
      Color(0xFFF7C60B); // Hex: #F7C60B
  static const Color _candleBearishWickDefault =
      Color(0xFFC40025); // Hex: #C40025
  static const Color _candleBearishWickColorBlind =
      Color(0xFFBD9808); // Hex: #BD9808

  //--------------------------------------------------------------------------
  // Current spot default colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color _currentSpotDefaultContainerLight =
      Color(0xFF181C25); // Hex: #181C25
  static const Color _currentSpotDefaultContainerDark =
      Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color _currentSpotDefaultLabelLight =
      Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color _currentSpotDefaultLabelDark =
      Color(0xFF181C25); // Hex: #181C25

  //--------------------------------------------------------------------------
  // Current spot Deriv colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color _currentSpotDerivContainer =
      Color(0xFFFF444F); // Hex: #FF444F
  static const Color _currentSpotDerivLabel = Color(0xFFFFFFFF); // Hex: #FFFFFF

  //--------------------------------------------------------------------------
  // Current spot Champion colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color _currentSpotChampionContainer =
      Color(0xFF00D0FF); // Hex: #00D0FF
  static const Color _currentSpotChampionLabel =
      Color(0xFF00375C); // Hex: #00375C

  //--------------------------------------------------------------------------
  // Crosshair colors for light and dark mode.
  //--------------------------------------------------------------------------
  static const Color _crosshairGridLight =
      Color(0x3D181C25); // Hex: #181C25 with 24% opacity
  static const Color _crosshairGridDark =
      Color(0x3DFFFFFF); // Hex: #FFFFFF with 24% opacity
  static const Color _crosshairTextLight = Color(0xFF181C25); // Hex: #181C25
  static const Color _crosshairTextDark = Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color _crosshairContainerLight =
      Color(0xFFF6F7F8); // Hex: #F6F7F8
  static const Color _crosshairContainerDark =
      Color(0xFF20242F); // Hex: #20242F

  //--------------------------------------------------------------------------
  // Getters for background color based on mode setting.
  //--------------------------------------------------------------------------
  static Color getBackgroundColor({ChartMode mode = ChartMode.light}) {
    return mode == ChartMode.dark
        ? _backgroundDynamicDark
        : _backgroundDynamicLight;
  }

  //--------------------------------------------------------------------------
  // Getter for bullish candle colors based on accessibility.
  //--------------------------------------------------------------------------
  static ({Color body, Color wick}) getBullishCandleColors({
    ChartAccessibility accessibility = ChartAccessibility.normal,
  }) {
    return (
      body: accessibility == ChartAccessibility.colorblind
          ? _candleBullishBodyColorBlind
          : _candleBullishBodyDefault,
      wick: accessibility == ChartAccessibility.colorblind
          ? _candleBullishWickColorBlind
          : _candleBullishWickDefault,
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
          ? _candleBearishBodyColorBlind
          : _candleBearishBodyDefault,
      wick: accessibility == ChartAccessibility.colorblind
          ? _candleBearishWickColorBlind
          : _candleBearishWickDefault,
    );
  }

  //--------------------------------------------------------------------------
  // Getter for axis colors based on mode.
  //--------------------------------------------------------------------------
  static ({Color grid, Color text}) getAxisColors({
    ChartMode mode = ChartMode.light,
  }) {
    return (
      grid:
          mode == ChartMode.dark ? _axisGridDefaultDark : _axisGridDefaultLight,
      text:
          mode == ChartMode.dark ? _axisTextDefaultDark : _axisTextDefaultLight,
    );
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
              ? _areaDefaultLineDark
              : _areaDefaultLineLight,
          gradientStart: mode == ChartMode.dark
              ? _areaDefaultGradientStartDark
              : _areaDefaultGradientStartLight,
          gradientEnd: mode == ChartMode.dark
              ? _areaDefaultGradientEndDark
              : _areaDefaultGradientEndLight,
        );
      case ChartVariant.deriv:
        return (
          line: _areaDerivLine,
          gradientStart: _areaDerivGradientStart,
          gradientEnd: _areaDerivGradientEnd,
        );
      case ChartVariant.champion:
        return (
          line: _areaChampionLine,
          gradientStart: _areaChampionGradientStart,
          gradientEnd: _areaChampionGradientEnd,
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
              ? _currentSpotDefaultContainerDark
              : _currentSpotDefaultContainerLight,
          label: mode == ChartMode.dark
              ? _currentSpotDefaultLabelDark
              : _currentSpotDefaultLabelLight,
        );
      case ChartVariant.deriv:
        return (
          container: _currentSpotDerivContainer,
          label: _currentSpotDerivLabel,
        );
      case ChartVariant.champion:
        return (
          container: _currentSpotChampionContainer,
          label: _currentSpotChampionLabel,
        );
    }
  }

  //--------------------------------------------------------------------------
  // Getter for crosshair colors based on mode.
  //--------------------------------------------------------------------------
  static ({Color grid, Color text, Color container}) getCrosshairColors({
    ChartMode mode = ChartMode.light,
  }) {
    return (
      grid: mode == ChartMode.dark ? _crosshairGridDark : _crosshairGridLight,
      text: mode == ChartMode.dark ? _crosshairTextDark : _crosshairTextLight,
      container: mode == ChartMode.dark
          ? _crosshairContainerDark
          : _crosshairContainerLight,
    );
  }
}
