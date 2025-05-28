// ignore_for_file: public_member_api_docs

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/theme/painting_styles/bar_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/entry_spot_style.dart';
import 'package:flutter/material.dart';

import 'dimens.dart';
import 'text_styles.dart';

/// Provides access to common theme-related colors and styles between default
/// light and dark themes.
abstract class ChartDefaultTheme implements ChartTheme {
  final Map<TextStyle, Map<Color, TextStyle>> _textStyle =
      <TextStyle, Map<Color, TextStyle>>{};

  @override
  TextStyle get currentSpotTextStyle => TextStyles.currentSpotTextStyle;

  @override
  TextStyle get gridTextStyle => TextStyles.gridTextStyle;

  @override
  double get margin04Chart => Dimens.margin04;

  @override
  double get margin08Chart => Dimens.margin08;

  @override
  double get margin12Chart => Dimens.margin12;

  @override
  double get margin16Chart => Dimens.margin16;

  @override
  double get margin24Chart => Dimens.margin24;

  @override
  double get margin32Chart => Dimens.margin32;

  @override
  double get borderRadius04Chart => Dimens.borderRadius04;

  @override
  double get borderRadius08Chart => Dimens.borderRadius08;

  @override
  double get borderRadius16Chart => Dimens.borderRadius16;

  @override
  double get borderRadius24Chart => Dimens.borderRadius24;

  @override
  String get fontFamily => TextStyles.appFontFamily;

  @override
  TextStyle get caption2 => TextStyles.caption2;

  @override
  TextStyle get subheading => TextStyles.subheading;

  @override
  TextStyle get body2 => TextStyles.body2;

  @override
  TextStyle get body1 => TextStyles.body1;

  @override
  TextStyle get title => TextStyles.title;

  @override
  Color get candleBullishBodyDefault =>
      CandleBullishThemeColors.candleBullishBodyDefault;

  @override
  Color get candleBullishBodyActive =>
      CandleBullishThemeColors.candleBullishBodyActive;

  @override
  Color get candleBullishWickDefault =>
      CandleBullishThemeColors.candleBullishWickDefault;

  @override
  Color get candleBullishWickActive =>
      CandleBullishThemeColors.candleBullishWickActive;

  @override
  Color get candleBearishBodyDefault =>
      CandleBearishThemeColors.candleBearishBodyDefault;

  @override
  Color get candleBearishBodyActive =>
      CandleBearishThemeColors.candleBearishBodyActive;

  @override
  Color get candleBearishWickDefault =>
      CandleBearishThemeColors.candleBearishWickDefault;

  @override
  Color get candleBearishWickActive =>
      CandleBearishThemeColors.candleBearishWickActive;

  @override
  double get crosshairInformationBoxContainerGlassBackgroundBlur =>
      Dimens.crosshairInformationBoxContainerGlassBackgroundBlur;

  @override
  TextStyle get crosshairInformationBoxTitleStyle =>
      TextStyles.crosshairInformationBoxTitleStyle;

  @override
  TextStyle get crosshairInformationBoxQuoteStyle =>
      TextStyles.crosshairInformationBoxQuoteStyle;

  @override
  TextStyle get crosshairInformationBoxTimeLabelStyle =>
      TextStyles.crosshairInformationBoxTimeLabelStyle;

  @override
  TextStyle get crosshairAxisLabelStyle => TextStyles.crosshairAxisLabelStyle;

  @override
  double get areaLineThickness => Dimens.areaLineDefaultThickness;

  @override
  CandleStyle get candleStyle => CandleStyle(
        neutralColor: base04Color,
        candleBullishWickColor: candleBullishWickDefault,
        candleBearishWickColor: candleBearishWickDefault,
      );

  @override
  BarStyle get barStyle => const BarStyle(
        positiveColor: LegacyLightThemeColors.accentGreen,
      );

  @override
  LineStyle get lineStyle => const LineStyle();

  // TODO(Ramin): Use the values from the chart theme itself. so if later the
  // theme changes the default styles also get updated accordingly.
  @override
  MarkerStyle get markerStyle => const MarkerStyle();

  @override
  EntrySpotStyle get entrySpotStyle => const EntrySpotStyle();

  @override
  HorizontalBarrierStyle get horizontalBarrierStyle => HorizontalBarrierStyle(
        color: base04Color,
        titleBackgroundColor: backgroundColor,
        textStyle: TextStyles.overLine,
      );

  @override
  VerticalBarrierStyle get verticalBarrierStyle => const VerticalBarrierStyle(
        textStyle: TextStyles.overLine,
      );

  TextStyle _getStyle({
    required TextStyle textStyle,
    required Color color,
  }) {
    _textStyle.putIfAbsent(textStyle, () => <Color, TextStyle>{});
    _textStyle[textStyle]!
        .putIfAbsent(color, () => textStyle.copyWith(color: color));

    // We already did put `_textStyle[textStyle][color]` if they were absent.
    // So using `!` is safe.
    return _textStyle[textStyle]![color]!;
  }

  @override
  TextStyle textStyle({
    required TextStyle textStyle,
    Color? color,
  }) {
    color ??= LegacyDarkThemeColors.base01;

    return _getStyle(textStyle: textStyle, color: color);
  }
}
