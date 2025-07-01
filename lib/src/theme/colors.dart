// ignore_for_file: public_member_api_docs

import 'package:deriv_chart/src/theme/design_tokens/component_design_tokens.dart';
import 'package:deriv_chart/src/theme/design_tokens/dark_theme_design_tokens.dart';
import 'package:deriv_chart/src/theme/design_tokens/light_theme_design_tokens.dart';
import 'package:flutter/material.dart';

/// Deriv branding colors, these colors should not be changed. It can be called
/// as [BrandColors.coral].
class BrandColors {
  static const Color coral = Color(0xFFFF444F);
  static const Color greenish = Color(0xFF85ACB0);
  static const Color orange = Color(0xFFFF6444);
}

/// These colors suits the dark theme of Deriv.
/// They are used in the legacy chart and should be replaced with the new colours from DarkThemeColors
class LegacyDarkThemeColors {
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
// They are used in the legacy chart and should be replaced with the new colours from LightThemeColors
class LegacyLightThemeColors {
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
class LightThemeColors {
  static const Color backgroundDynamicHighest = LightThemeDesignTokens
      .semanticColorSlateSolidSurfaceFrameLow; // Hex: #FFFFFF
  static final Color gridLineColor = LightThemeDesignTokens
      .semanticColorMonochromeBorderNormalLow; // Hex: #000000 with 4% opacity
  static final Color gridTextColor = ComponentDesignTokens
      .componentTextIconNormalDisabledLight; // Hex: #000000 with 24% opacity

  static const Color areaLineColor = LightThemeDesignTokens
      .semanticColorSlateSolidBorderInverseLowest; // Hex: #181C25
  static final Color areaGradientStart = LightThemeDesignTokens
      .semanticColorMonochromeSurfaceNormalMidLow; // Hex: #181C25 with 16% opacity
  static const Color areaGradientEnd = Color(
      0x00000000); // Hex: #000000 with 0% opacity //TODO(Jim): update this value with corresponding design token when available

  static const Color currentSpotContainerColor = LightThemeDesignTokens
      .semanticColorSlateSolidSurfaceInverseLowest; // Hex: #000000
  static const Color currentSpotDotColor = LightThemeDesignTokens
      .semanticColorSlateSolidSurfaceInverseLowest; // Hex: #000000
  static final Color currentSpotDotEffect = LightThemeDesignTokens
      .semanticColorMonochromeSurfaceNormalMidLow; // Hex: #000000 with 16% opacity
  static const Color currentSpotLineColor = LightThemeDesignTokens
      .semanticColorSlateSolidSurfaceInverseLowest; // Hex: #000000
  static const Color currentSpotTextColor = ComponentDesignTokens
      .componentTextIconInverseProminentLight; // Hex: #FFFFFF

  static final Color crosshairLineDesktopColor = LightThemeDesignTokens
      .semanticColorMonochromeBorderNormalHighest; // Hex: #000000 with 24% opacity
  static const Color crosshairLineResponsiveUpperLineGradientStart = Color(
      0x00000000); // Hex: #000000 with 0% opacity //TODO(Jim): update this value with corresponding design token when available
  static final Color crosshairLineResponsiveUpperLineGradientEnd =
      LightThemeDesignTokens
          .semanticColorMonochromeSurfaceNormalMidHigh; // Hex: #000000 with 24% opacity
  static final Color crosshairLineResponsiveLowerLineGradientStart =
      LightThemeDesignTokens
          .semanticColorMonochromeSurfaceNormalMidHigh; // Hex: #000000 with 24% opacity
  static const Color crosshairLineResponsiveLowerLineGradientEnd = Color(
      0x00000000); // Hex: #000000 with 0% opacity //TODO(Jim): update this value with corresponding design token when available

  static const Color crosshairInformationBoxTextDefault = ComponentDesignTokens
      .componentTextIconNormalProminentLight; // Hex: #181C25
  static final Color crosshairInformationBoxTextSubtle = ComponentDesignTokens
      .componentTextIconNormalSubtleLight; // Hex: #000000 with 48% opacity
  static const Color crosshairInformationBoxTextStatic = ComponentDesignTokens
      .componentTextIconStaticProminentDark; // Hex: #FFFFFF
  static const Color crosshairInformationBoxTextProfit = LightThemeDesignTokens
      .semanticColorEmeraldSolidSurfaceStaticHigh; // Hex: #00AE7A
  static const Color crosshairInformationBoxTextLoss = LightThemeDesignTokens
      .semanticColorCherrySolidSurfaceStaticHigh; // Hex: #C40025
  static const Color crosshairInformationBoxContainerNormalColor =
      LightThemeDesignTokens
          .semanticColorSlateSolidSurfaceFrameMid; // Hex: #F6F7F8
  static final Color crosshairInformationBoxContainerGlassColor =
      LightThemeDesignTokens
          .semanticColorMonochromeSurfaceNormalLowest; // Hex: #000000 with 4% opacity

  static final Color floatingMenuContainerGlassColor = LightThemeDesignTokens
      .semanticColorMonochromeSurfaceNormalLowest; // Hex: #000000 with 4% opacity
  static final Color floatingMenuDragIconColor = LightThemeDesignTokens
      .semanticColorMonochromeTextIconNormalMid; // Hex: #000000 with appropriate opacity

  static const Color lineThicknessDropdownButtonTextColor =
      ComponentDesignTokens
          .componentTextIconNormalProminentLight; // Hex: #000000
  static const Color lineThicknessDropdownItemSelectedBackgroundColor =
      ComponentDesignTokens
          .componentDropdownItemBgSelectedLight; // Hex: #FFFFFF
  static const Color lineThicknessDropdownItemSelectedTextColor =
      ComponentDesignTokens
          .componentTextIconInverseProminentLight; // Hex: #000000
  static final Color lineThicknessDropdownItemUnselectedTextColor =
      ComponentDesignTokens.componentTextIconNormalDefaultLight; // Hex: #FFFFFF
  static const Color lineThicknessDropdownItemSelectedLineColor =
      ComponentDesignTokens
          .componentTextIconInverseProminentLight; // Hex: #000000
  static final Color lineThicknessDropdownItemUnselectedLineColor =
      ComponentDesignTokens.componentTextIconNormalDefaultLight; // Hex: #FFFFFF

  // Toolbar color palette colors
  static const Color toolbarColorPaletteIconRed =
      LightThemeDesignTokens.semanticColorRedSolidSurfaceInverseMid;
  static const Color toolbarColorPaletteIconYellow =
      LightThemeDesignTokens.semanticColorYellowSolidSurfaceInverseMid;
  static const Color toolbarColorPaletteIconMustard =
      LightThemeDesignTokens.semanticColorMustardSolidSurfaceInverseMid;
  static const Color toolbarColorPaletteIconGreen =
      LightThemeDesignTokens.semanticColorGreenSolidSurfaceInverseMid;
  static const Color toolbarColorPaletteIconSeaWater =
      LightThemeDesignTokens.semanticColorSeawaterSolidSurfaceInverseMid;
  static const Color toolbarColorPaletteIconBlue =
      LightThemeDesignTokens.semanticColorBlueSolidSurfaceInverseMid;
  static const Color toolbarColorPaletteIconSapphire =
      LightThemeDesignTokens.semanticColorSapphireSolidSurfaceInverseMid;
  static const Color toolbarColorPaletteIconBlueBerry =
      LightThemeDesignTokens.semanticColorBlueberrySolidSurfaceInverseMid;
  static const Color toolbarColorPaletteIconGrape =
      LightThemeDesignTokens.semanticColorGrapeSolidSurfaceInverseMid;
  static const Color toolbarColorPaletteIconMagenta =
      LightThemeDesignTokens.semanticColorMagentaSolidSurfaceInverseMid;
  static final Color toolbarColorPaletteIconBorderColor =
      LightThemeDesignTokens.semanticColorMonochromeBorderNormalHigh;
}

/// Default colors for dark theme.
class DarkThemeColors {
  static const Color backgroundDynamicHighest = DarkThemeDesignTokens
      .semanticColorSlateSolidSurfaceFrameLow; // Hex: #181C25
  static final Color gridLineColor = DarkThemeDesignTokens
      .semanticColorMonochromeBorderNormalLow; // Hex: #000000 with 4% opacity
  static final Color gridTextColor = ComponentDesignTokens
      .componentTextIconNormalDisabledDark; // Hex: #000000 with 24% opacity

  static const Color areaLineColor = DarkThemeDesignTokens
      .semanticColorSlateSolidBorderInverseLowest; // Hex: #181C25
  static final Color areaGradientStart = DarkThemeDesignTokens
      .semanticColorMonochromeSurfaceNormalMidLow; // Hex: #181C25 with 16% opacity
  static const Color areaGradientEnd = Color(
      0x00FFFFFF); // Hex: #FFFFFF with 0% opacity //TODO(Jim): update this value with corresponding design token when available

  static const Color currentSpotContainerColor = DarkThemeDesignTokens
      .semanticColorSlateSolidSurfaceInverseLowest; // Hex: #000000
  static const Color currentSpotDotColor = DarkThemeDesignTokens
      .semanticColorSlateSolidSurfaceInverseLowest; // Hex: #000000
  static final Color currentSpotDotEffect = DarkThemeDesignTokens
      .semanticColorMonochromeSurfaceNormalMidLow; // Hex: #000000 with 16% opacity
  static const Color currentSpotLineColor = DarkThemeDesignTokens
      .semanticColorSlateSolidSurfaceInverseLowest; // Hex: #000000
  static const Color currentSpotTextColor = ComponentDesignTokens
      .componentTextIconInverseProminentDark; // Hex: #FFFFFF

  static final Color crosshairLineDesktopColor = DarkThemeDesignTokens
      .semanticColorMonochromeBorderNormalHighest; // Hex: #000000 with 24% opacity
  static const Color crosshairLineResponsiveUpperLineGradientStart = Color(
      0x00FFFFFF); // Hex: #FFFFFF with 0% opacity //TODO(Jim): update this value with corresponding design token when available
  static final Color crosshairLineResponsiveUpperLineGradientEnd =
      DarkThemeDesignTokens
          .semanticColorMonochromeSurfaceNormalMidHigh; // Hex: #000000 with 24% opacity
  static final Color crosshairLineResponsiveLowerLineGradientStart =
      DarkThemeDesignTokens
          .semanticColorMonochromeSurfaceNormalMidHigh; // Hex: #000000 with 24% opacity
  static const Color crosshairLineResponsiveLowerLineGradientEnd = Color(
      0x00FFFFFF); // Hex: #FFFFFF with 0% opacity //TODO(Jim): update this value with corresponding design token when available

  static const Color crosshairInformationBoxTextDefault = ComponentDesignTokens
      .componentTextIconNormalProminentDark; // Hex: #181C25
  static final Color crosshairInformationBoxTextSubtle = ComponentDesignTokens
      .componentTextIconNormalSubtleDark; // Hex: #000000 with 48% opacity
  static const Color crosshairInformationBoxTextStatic = ComponentDesignTokens
      .componentTextIconStaticProminentDark; // Hex: #FFFFFF
  static const Color crosshairInformationBoxTextProfit = DarkThemeDesignTokens
      .semanticColorEmeraldSolidSurfaceStaticMid; // Hex: #00c390
  static const Color crosshairInformationBoxTextLoss = DarkThemeDesignTokens
      .semanticColorCherrySolidSurfaceStaticMid; // Hex: #de0040
  static const Color crosshairInformationBoxContainerNormalColor =
      DarkThemeDesignTokens
          .semanticColorSlateSolidSurfaceFrameMid; // Hex: #F6F7F8
  static final Color crosshairInformationBoxContainerGlassColor =
      DarkThemeDesignTokens
          .semanticColorMonochromeSurfaceNormalLowest; // Hex: #000000 with 4% opacity

  // Floating menu container glass background color
  static final Color floatingMenuContainerGlassColor = DarkThemeDesignTokens
      .semanticColorMonochromeSurfaceNormalLowest; // Hex: #000000 with 4% opacity

  // Floating menu drag icon color
  static final Color floatingMenuDragIconColor = DarkThemeDesignTokens
      .semanticColorMonochromeTextIconNormalMid; // Hex: #000000 with appropriate opacity

  // Line thickness dropdown colors
  static const Color lineThicknessDropdownButtonTextColor =
      ComponentDesignTokens
          .componentTextIconNormalProminentDark; // Hex: #FFFFFF

  static const Color lineThicknessDropdownItemSelectedBackgroundColor =
      ComponentDesignTokens.componentDropdownItemBgSelectedDark; // Hex: #FFFFFF
  static const Color lineThicknessDropdownItemSelectedTextColor =
      ComponentDesignTokens
          .componentTextIconInverseProminentDark; // Hex: #000000
  static const Color lineThicknessDropdownItemUnselectedTextColor =
      ComponentDesignTokens
          .componentTextIconNormalProminentDark; // Hex: #FFFFFF
  static const Color lineThicknessDropdownItemSelectedLineColor =
      ComponentDesignTokens
          .componentTextIconInverseProminentDark; // Hex: #000000
  static const Color lineThicknessDropdownItemUnselectedLineColor =
      ComponentDesignTokens
          .componentTextIconNormalProminentDark; // Hex: #FFFFFF

  // Toolbar color palette colors
  static const Color toolbarColorPaletteIconRed =
      DarkThemeDesignTokens.semanticColorRedSolidSurfaceInverseMid;
  static const Color toolbarColorPaletteIconYellow =
      DarkThemeDesignTokens.semanticColorYellowSolidSurfaceInverseMid;
  static const Color toolbarColorPaletteIconMustard =
      DarkThemeDesignTokens.semanticColorMustardSolidSurfaceInverseMid;
  static const Color toolbarColorPaletteIconGreen =
      DarkThemeDesignTokens.semanticColorGreenSolidSurfaceInverseMid;
  static const Color toolbarColorPaletteIconSeaWater =
      DarkThemeDesignTokens.semanticColorSeawaterSolidSurfaceInverseMid;
  static const Color toolbarColorPaletteIconBlue =
      DarkThemeDesignTokens.semanticColorBlueSolidSurfaceInverseMid;
  static const Color toolbarColorPaletteIconSapphire =
      DarkThemeDesignTokens.semanticColorSapphireSolidSurfaceInverseMid;
  static const Color toolbarColorPaletteIconBlueBerry =
      DarkThemeDesignTokens.semanticColorBlueberrySolidSurfaceInverseMid;
  static const Color toolbarColorPaletteIconGrape =
      DarkThemeDesignTokens.semanticColorGrapeSolidSurfaceInverseMid;
  static const Color toolbarColorPaletteIconMagenta =
      DarkThemeDesignTokens.semanticColorMagentaSolidSurfaceInverseMid;
  static final Color toolbarColorPaletteIconBorderColor =
      DarkThemeDesignTokens.semanticColorMonochromeBorderNormalHigh;
}

/// Candle Bullish colors for light, dark
class CandleBullishThemeColors {
  static const Color candleBullishBodyDefault = LightThemeDesignTokens
      .semanticColorEmeraldSolidSurfaceStaticMid; // Hex: #00c390
  static const Color candleBullishBodyActive = LightThemeDesignTokens
      .semanticColorEmeraldSolidSurfaceStaticLow; // Hex: #4DECBC
  static const Color candleBullishWickDefault = LightThemeDesignTokens
      .semanticColorEmeraldSolidSurfaceStaticHigh; // Hex: #00AE7A
  static const Color candleBullishWickActive = LightThemeDesignTokens
      .semanticColorEmeraldSolidSurfaceStaticLow; // Hex: #4DECBC
}

/// Candle Bearish colors for light, dark
class CandleBearishThemeColors {
  static const Color candleBearishBodyDefault = LightThemeDesignTokens
      .semanticColorCherrySolidSurfaceStaticMid; // Hex: #de0040
  static const Color candleBearishBodyActive = LightThemeDesignTokens
      .semanticColorCherrySolidSurfaceStaticLow; // Hex: #FF4D6E
  static const Color candleBearishWickDefault = LightThemeDesignTokens
      .semanticColorCherrySolidSurfaceStaticHigh; // Hex: #C40025
  static const Color candleBearishWickActive = LightThemeDesignTokens
      .semanticColorCherrySolidSurfaceStaticLow; // Hex: #FF4D6E
}
