// ignore_for_file: public_member_api_docs
import 'dart:ui';

import 'package:flutter/material.dart';

/// An interface for the Chart's theme.
///
/// Any app which wants to define the chart's theme should pass an implementation of this interface.
abstract class ChartTheme {
  bool get isDarkTheme;

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

  TextStyle get caption2;

  /// The style of text is generated by calling this function,
  ///
  /// The [textStyle] argument must not be null, and if null is passed, an
  /// ArgumentError will be thrown
  ///
  /// The [color] may be null or un-passed, in that case, a default value will
  /// be assigned to it
  TextStyle textStyle({
    @required TextStyle textStyle,
    Color color,
  });

  /// Switch the brightness of the theme.
  void updateTheme({@required Brightness brightness});
}
