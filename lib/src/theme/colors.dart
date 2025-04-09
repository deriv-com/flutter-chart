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

/// Default colors for light theme.
class DefaultLightThemeColors {
  static const Color backgroundDynamicHighest =
      Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color axisGridDefault =
      Color(0x0A181C25); // Hex: #181C25 with 4% opacity
  static const Color axisTextDefault =
      Color(0x3D181C25); // Hex: #181C25 with 24% opacity
  static const Color areaDefaultLine = Color(0xFF181C25); // Hex: #181C25
  static const Color areaDefaultGradientStart =
      Color(0x29181C25); // Hex: #181C25 with 16% opacity
  static const Color areaDefaultGradientEnd =
      Color(0x00181C25); // Hex: #181C25 with 0% opacity
  static const Color currentSpotDefaultContainer =
      Color(0xFF181C25); // Hex: #181C25
  static const Color currentSpotDefaultLabel =
      Color(0xFFFFFFFF); // Hex: #FFFFFF
//   static const Color crosshairGrid =
//       Color(0x3D181C25); // Hex: #181C25 with 24% opacity
  static const Color crosshairText = Color(0xFF181C25); // Hex: #181C25
  static const Color crosshairLineDesktop =
      Color(0x3D181C25); // Hex: #181C25 with 24% opacity
  static const Color crosshairLineResponsiveUpperLineGradientStart =
      Color(0x00181C25); // Hex: #181C25 with 0% opacity
  static const Color crosshairLineResponsiveUpperLineGradientEnd =
      Color(0x3D181C25); // Hex: #181C25 with 24% opacity
  static const Color crosshairLineResponsiveLowerLineGradientStart =
      Color(0x3D181C25); // Hex: #181C25 with 24% opacity
  static const Color crosshairLineResponsiveLowerLineGradientEnd =
      Color(0x00181C25); // Hex: #181C25 with 0% opacity
  static const Color crosshairInformationBoxTextDefault =
      Color(0xFF181C25); // Hex: #181C25
  static const Color crosshairInformationBoxTextSubtle =
      Color(0x7A181C25); // Hex: #181C25 with 48% opacity
  static const Color crosshairInformationBoxTextStatic =
      Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color crosshairInformationBoxTextProfit =
      Color(0xFF00C390); // Hex: #00C390
  static const Color crosshairInformationBoxTextLoss =
      Color(0xFFDE0040); // Hex: #DE0040
  static const Color crosshairInformationBoxContainerDefault =
      Color(0xFFF6F7F8); // Hex: #F6F7F8
  static const Color crosshairInformationBoxContainerGlass =
      Color(0x0A181C25); // Hex: #181C25 with 4% opacity
  static const Color crosshairDot = Color(0xFF181C25); // Hex: #181C25
  static const Color crosshairDotEffect =
      Color(0x29181C25); // Hex: #181C25 with 16% opacity
  static const Color line = Color(0x7A181C25); // #181C25 with 48% opacity
  static const Color text = Color(0xFF181C25); // #181C25
  static const Color subtitle = Color(0xFF181C25); // #181C25
  static const Color container = Color(0xFFF6F7F8); // #F6F7F8
  static const Color gradientStart =
      Color(0x00181C25); // #181C25 with 0% opacity
  static const Color gradientEnd = Color(0x00181C25); // #181C25 with 0% opacity
  static const Color dot = Color(0xFF181C25); // #181C25
  static const Color effect = Color(0x29181C25); // #181C25 with 16% opacity
  static const Color subtitle2 = Color(0x7A181C25); // #181C25 with 48% opacity
  static const Color desktop = Color(0xFF181C25); // #181C25
}

/// Default colors for dark theme.
class DefaultDarkThemeColors {
  static const Color backgroundDynamicHighest =
      Color(0xFF181C25); // Hex: #181C25
  static const Color axisGridDefault =
      Color(0x0AFFFFFF); // Hex: #FFFFFF with 4% opacity
  static const Color axisTextDefault =
      Color(0x3DFFFFFF); // Hex: #FFFFFF with 24% opacity
  static const Color areaDefaultLine = Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color areaDefaultGradientStart =
      Color(0x29FFFFFF); // Hex: #FFFFFF with 16% opacity
  static const Color areaDefaultGradientEnd =
      Color(0x00FFFFFF); // Hex: #FFFFFF with 0% opacity
  static const Color currentSpotDefaultContainer =
      Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color currentSpotDefaultLabel =
      Color(0xFF181C25); // Hex: #181C25
//   static const Color crosshairGrid =
//       Color(0x3DFFFFFF); // Hex: #FFFFFF with 24% opacity
  static const Color crosshairText = Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color crosshairInformationBoxContainer =
      Color(0xFF20242F); // Hex: #20242F
  static const Color crosshairContainerGlass =
      Color(0x0AFFFFFF); // Hex: #FFFFFF with 4% opacity
  static const Color crosshairLineDesktop =
      Color(0x3DFFFFFF); // Hex: #FFFFFF with 24% opacity
  static const Color crosshairLineResponsiveUpperLineGradientStart =
      Color(0x00FFFFFF); // Hex: #FFFFFF with 0% opacity
  static const Color crosshairLineResponsiveUpperLineGradientEnd =
      Color(0x3DFFFFFF); // Hex: #FFFFFF with 24% opacity
  static const Color crosshairLineResponsiveLowerLineGradientStart =
      Color(0x3DFFFFFF); // Hex: #FFFFFF with 24% opacity
  static const Color crosshairLineResponsiveLowerLineGradientEnd =
      Color(0x00FFFFFF); // Hex: #FFFFFF with 0% opacity
  static const Color crosshairInformationBoxTextDefault =
      Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color crosshairInformationBoxTextSubtle =
      Color(0x7AFFFFFF); // Hex: #FFFFFF with 48% opacity
  static const Color crosshairInformationBoxTextStatic =
      Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color crosshairInformationBoxTextProfit =
      Color(0xFF00C390); // Hex: #00C390
  static const Color crosshairInformationBoxTextLoss =
      Color(0xFFDE0040); // Hex: #DE0040
  static const Color crosshairDot = Color(0xFFFFFFFF); // Hex: #FFFFFF
  static const Color crosshairDotEffect =
      Color(0x29FFFFFF); // Hex: #FFFFFF with 16% opacity
  static const Color line = Color(0x7AFFFFFF); // #FFFFFF with 48% opacity
  static const Color text = Color(0xFFFFFFFF); // #FFFFFF
  static const Color subtitle = Color(0xFFFFFFFF); // #FFFFFF
  static const Color container = Color(0xFF20242F); // #20242F
  static const Color gradientStart =
      Color(0x00FFFFFF); // #FFFFFF with 0% opacity
  static const Color gradientEnd = Color(0x00FFFFFF); // #FFFFFF with 0% opacity
  static const Color dot = Color(0xFFFFFFFF); // #FFFFFF
  static const Color effect = Color(0x29FFFFFF); // #FFFFFF with 16% opacity
  static const Color subtitle2 = Color(0x7AFFFFFF); // #FFFFFF with 48% opacity
  static const Color desktop = Color(0xFFFFFFFF); // #FFFFFF
}

/// Deriv theme colors
class DerivThemeColors {
  static const Color areaDerivLine = Color(0xFFFF444F); // Hex: #FF444F
  static const Color areaDerivGradientStart =
      Color(0x29FF444F); // Hex: #FF444F with 16% opacity
  static const Color areaDerivGradientEnd =
      Color(0x00FF444F); // Hex: #FF444F with 0% opacity
  static const Color currentSpotDerivContainer =
      Color(0xFFFF444F); // Hex: #FF444F
  static const Color currentSpotDerivLabel = Color(0xFFFFFFFF); // Hex: #FFFFFF
}

/// Champion theme colors
class ChampionThemeColors {
  static const Color areaChampionLine = Color(0xFF00D0FF); // Hex: #00D0FF
  static const Color areaChampionGradientStart =
      Color(0x2900D0FF); // Hex: #00D0FF with 16% opacity
  static const Color areaChampionGradientEnd =
      Color(0x0000D0FF); // Hex: #00D0FF with 0% opacity
  static const Color currentSpotChampionContainer =
      Color(0xFF00D0FF); // Hex: #00D0FF
  static const Color currentSpotChampionLabel =
      Color(0xFF00375C); // Hex: #00375C
}

/// Candle Bullish colors for light, dark, and colorblind themes
class CandleBullishThemeColors {
  static const Color candleBullishBodyDefault =
      Color(0xFF00C390); // Hex: #00C390
  static const Color candleBullishBodyActive =
      Color(0xFF4DECBC); // Hex: #4DECBC
  static const Color candleBullishBodyColorBlind =
      Color(0xFF2C9AFF); // Hex: #2C9AFF
  static const Color candleBullishWickDefault =
      Color(0xFF00AE7A); // Hex: #00AE7A
  static const Color candleBullishWickActive =
      Color(0xFF4DECBC); // Hex: #4DECBC
  static const Color candleBullishWickColorBlind =
      Color(0xFF0777C4); // Hex: #0777C4
}

/// Candle Bearish colors for light, dark, and colorblind themes
class CandleBearishThemeColors {
  static const Color candleBearishBodyDefault =
      Color(0xFFDE0040); // Hex: #DE0040
  static const Color candleBearishBodyActive =
      Color(0xFFFF4D6E); // Hex: #FF4D6E
  static const Color candleBearishBodyColorBlind =
      Color(0xFFF7C60B); // Hex: #F7C60B
  static const Color candleBearishWickDefault =
      Color(0xFFC40025); // Hex: #C40025
  static const Color candleBearishWickActive =
      Color(0xFFFF4D6E); // Hex: #FF4D6E
  static const Color candleBearishWickColorBlind =
      Color(0xFFBD9808); // Hex: #BD9808
}
