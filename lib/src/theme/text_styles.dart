// ignore_for_file: public_member_api_docs

import 'dart:ui';

import 'package:flutter/material.dart';

/// This include all text styles according to Deriv theme guideline.
class TextStyles {
  static const String appFontFamily = 'IBMPlexSans';

  static TextStyle display1 = const TextStyle(
      fontFamily: appFontFamily,
      fontSize: 34,
      height: 1.5,
      fontWeight: FontWeight.normal);

  static TextStyle headline = const TextStyle(
      fontFamily: appFontFamily,
      fontSize: 24,
      height: 1.5,
      fontWeight: FontWeight.w700);

  static TextStyle title = const TextStyle(
      fontFamily: appFontFamily,
      fontSize: 20,
      height: 1.5,
      fontWeight: FontWeight.w500);

  static TextStyle lightTitle = const TextStyle(
      fontFamily: appFontFamily,
      fontSize: 20,
      height: 1.5,
      fontWeight: FontWeight.w300);

  static TextStyle subheading = const TextStyle(
      fontFamily: appFontFamily,
      fontSize: 16,
      height: 1.25,
      fontWeight: FontWeight.normal);

  static TextStyle body2 = const TextStyle(
      fontFamily: appFontFamily,
      fontSize: 14,
      height: 1.4,
      fontWeight: FontWeight.w500);

  static TextStyle body1Bold = const TextStyle(
      fontFamily: appFontFamily,
      fontSize: 14,
      height: 1.3,
      fontWeight: FontWeight.bold);

  static TextStyle body1 = const TextStyle(
      fontFamily: appFontFamily,
      fontSize: 14,
      height: 1.3,
      fontWeight: FontWeight.normal);

  static TextStyle caption = const TextStyle(
      fontFamily: appFontFamily,
      fontSize: 12,
      height: 1.3,
      fontWeight: FontWeight.normal);

  static TextStyle caption2 = const TextStyle(
    fontFamily: appFontFamily,
    fontSize: 10,
    height: 1.3,
    fontWeight: FontWeight.normal,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  static TextStyle captionBold = const TextStyle(
      fontFamily: appFontFamily,
      fontSize: 12,
      height: 1.3,
      fontWeight: FontWeight.bold);

  static TextStyle button = const TextStyle(
      fontFamily: appFontFamily,
      fontSize: 14,
      height: 1,
      fontWeight: FontWeight.w500);

  static TextStyle overLine = const TextStyle(
      fontFamily: appFontFamily,
      fontSize: 10,
      height: 1.4,
      fontWeight: FontWeight.w400,
      fontFeatures: [FontFeature.tabularFigures()]);
}
