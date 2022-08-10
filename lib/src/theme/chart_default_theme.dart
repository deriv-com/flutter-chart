// ignore_for_file: public_member_api_docs

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/theme/painting_styles/bar_style.dart';
import 'package:flutter/material.dart';

import 'colors.dart';
import 'dimens.dart';
import 'text_styles.dart';

/// Provides access to common theme-related colors and styles between default
/// light and dark themes.
abstract class ChartDefaultTheme implements ChartTheme {
  final Map<TextStyle, Map<Color, TextStyle>> _textStyle =
      <TextStyle, Map<Color, TextStyle>>{};

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
  Color get brandCoralColor => BrandColors.coral;

  @override
  Color get brandGreenishColor => BrandColors.greenish;

  @override
  Color get brandOrangeColor => BrandColors.orange;

  @override
  GridStyle get gridStyle => GridStyle(
        gridLineColor: base07Color,
        xLabelStyle: textStyle(
          textStyle: caption2,
          color: base03Color,
        ),
        yLabelStyle: textStyle(
          textStyle: caption2,
          color: base03Color,
        ),
      );

  @override
  HorizontalBarrierStyle get currentTickStyle => HorizontalBarrierStyle(
        color: brandCoralColor,
        textStyle: textStyle(textStyle: caption2, color: base01Color),
      );

  @override
  CandleStyle get candleStyle => CandleStyle(
        positiveColor: accentGreenColor,
        negativeColor: accentRedColor,
        lineColor: base04Color,
      );

  @override
  BarStyle get barStyle => BarStyle(
        positiveColor: accentGreenColor,
        negativeColor: accentRedColor,
      );

  @override
  LineStyle get lineStyle => LineStyle(color: brandGreenishColor);

  @override
  MarkerStyle get markerStyle => MarkerStyle(
        upColor: accentGreenColor,
        downColor: accentRedColor,
      );

  @override
  HorizontalBarrierStyle get horizontalBarrierStyle => HorizontalBarrierStyle(
        color: base04Color,
        titleBackgroundColor: base08Color,
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
    color ??= DarkThemeColors.base01;

    return _getStyle(textStyle: textStyle, color: color);
  }
}
