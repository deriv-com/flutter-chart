// ignore_for_file: public_member_api_docs

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

import 'colors.dart';
import 'dimens.dart';
import 'painting_styles/candle_style.dart';
import 'painting_styles/grid_style.dart';
import 'painting_styles/line_style.dart';
import 'text_styles.dart';

/// Provides access to common theme-related colors and styles between default
/// light and dark themes
abstract class ChartDefaultTheme implements ChartTheme {
  final Map<TextStyle, Map<Color, TextStyle>> _textStyle =
      <TextStyle, Map<Color, TextStyle>>{};

  @override
  double get margin04 => Dimens.margin04;

  @override
  double get margin08 => Dimens.margin08;

  @override
  double get margin12 => Dimens.margin12;

  @override
  double get margin16 => Dimens.margin16;

  @override
  double get margin24 => Dimens.margin24;

  @override
  double get margin32 => Dimens.margin32;

  @override
  double get borderRadius04 => Dimens.borderRadius04;

  @override
  double get borderRadius08 => Dimens.borderRadius08;

  @override
  double get borderRadius16 => Dimens.borderRadius16;

  @override
  double get borderRadius24 => Dimens.borderRadius24;

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
        labelStyle: textStyle(
          textStyle: caption2,
          color: base03Color,
        ),
      );

  @override
  HorizontalBarrierStyle get currentTickStyle => HorizontalBarrierStyle(
        color: brandCoralColor,
        textStyle: textStyle(
          textStyle: caption2,
          color: base01Color,
        ),
      );

  @override
  CandleStyle get candleStyle => CandleStyle(
        positiveColor: accentGreenColor,
        negativeColor: accentRedColor,
        lineColor: base04Color,
      );

  @override
  LineStyle get lineStyle => LineStyle(color: brandGreenishColor);

  TextStyle _getStyle({
    @required TextStyle textStyle,
    @required Color color,
  }) {
    ArgumentError.checkNotNull(textStyle, 'textStyle');
    ArgumentError.checkNotNull(color, 'color');

    _textStyle.putIfAbsent(textStyle, () => <Color, TextStyle>{});
    _textStyle[textStyle]
        .putIfAbsent(color, () => textStyle.copyWith(color: color));

    return _textStyle[textStyle][color];
  }

  @override
  TextStyle textStyle({
    @required TextStyle textStyle,
    Color color,
  }) {
    ArgumentError.checkNotNull(textStyle, 'textStyle');

    color ??= DarkThemeColors.base01;

    return _getStyle(textStyle: textStyle, color: color);
  }
}
