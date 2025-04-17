// ignore_for_file: public_member_api_docs

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/theme/painting_styles/bar_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/entry_spot_style.dart';
import 'package:flutter/material.dart';

/// An interface for the Chart's theme.
///
/// Any app which wants to define the chart's theme should pass an
/// implementation of this interface.
abstract class ChartTheme {
  GridStyle get gridStyle;

  LineStyle get areaStyle;

  TextStyle get currentSpotTextStyle;

  Color get gridLineColor;

  Color get gridTextColor;

  TextStyle get gridTextStyle;

  Color get areaLineColor;

  double get areaLineThickness;

  Color get areaGradientStart;

  Color get areaGradientEnd;

  Color get candleBullishBodyDefault;

  Color get candleBullishBodyActive;

  Color get candleBullishWickDefault;

  Color get candleBullishWickActive;

  Color get candleBearishBodyDefault;

  Color get candleBearishBodyActive;

  Color get candleBearishWickDefault;

  Color get candleBearishWickActive;

  Color get currentSpotContainerColor;

  Color get currentSpotDotColor;

  Color get currentSpotDotEffect;

  Color get currentSpotLineColor;

  Color get currentSpotTextColor;

  Color get crosshairLineDesktopColor;

  Color get crosshairLineResponsiveUpperLineGradientStart;

  Color get crosshairLineResponsiveUpperLineGradientEnd;

  Color get crosshairLineResponsiveLowerLineGradientStart;

  Color get crosshairLineResponsiveLowerLineGradientEnd;

  Color get crosshairInformationBoxTextDefault;

  Color get crosshairInformationBoxTextSubtle;

  Color get crosshairInformationBoxTextStatic;

  Color get crosshairInformationBoxTextProfit;

  Color get crosshairInformationBoxTextLoss;

  Color get crosshairInformationBoxContainerNormalColor;

  Color get crosshairInformationBoxContainerGlassColor;

  double get crosshairInformationBoxContainerGlassBackgroundBlur;

  /// The style of the current tick indicator.
  HorizontalBarrierStyle get currentSpotStyle;

  String get fontFamily;

  Color get brandCoralColor;

  Color get brandGreenishColor;

  Color get brandOrangeColor;

  Color get accentRedColor;

  Color get accentGreenColor;

  Color get accentYellowColor;

  Color get base01Color;

  Color get base02Color;

  Color get base03Color;

  Color get base04Color;

  Color get base05Color;

  Color get base06Color;

  Color get base07Color;

  Color get base08Color;

  Color get hoverColor;

  double get margin04Chart;

  double get margin08Chart;

  double get margin12Chart;

  double get margin16Chart;

  double get margin24Chart;

  double get margin32Chart;

  double get borderRadius04Chart;

  double get borderRadius08Chart;

  double get borderRadius16Chart;

  double get borderRadius24Chart;

  TextStyle get caption2;

  TextStyle get subheading;

  TextStyle get body2;

  TextStyle get body1;

  TextStyle get title;

  TextStyle get overLine;

  /// The painting styles of candlestick chart.
  CandleStyle get candleStyle;

  /// The painting styles of histogram bar.
  BarStyle get barStyle;

  /// The painting styles of line chart.
  LineStyle get lineStyle;

  /// The painting styles of markers.
  MarkerStyle get markerStyle;

  /// The painting styles of accumulators entry spot.
  EntrySpotStyle get entrySpotStyle;

  /// The painting styles horizontal barriers.
  HorizontalBarrierStyle get horizontalBarrierStyle;

  /// The painting styles vertical barriers.
  VerticalBarrierStyle get verticalBarrierStyle;

  /// The style of text is generated by calling this function.
  ///
  /// The [textStyle] argument must not be null, and if null is passed, an
  /// ArgumentError will be thrown.
  ///
  /// The [color] may be null or un-passed, in that case, a default value will
  /// be assigned to it.
  TextStyle textStyle({
    required TextStyle textStyle,
    Color? color,
  });
}
