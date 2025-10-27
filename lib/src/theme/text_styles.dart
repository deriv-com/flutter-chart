// ignore_for_file: public_member_api_docs

import 'dart:ui';

import 'package:flutter/material.dart';

/// This include all text styles according to Deriv theme guideline.
class TextStyles {
  static const String appFontFamily = 'IBMPlexSans';

  static const TextStyle display1 = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 34,
    height: 1.5,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 24,
    height: 1.5,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle title = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 20,
    height: 1.5,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle lightTitle = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 20,
    height: 1.5,
    fontWeight: FontWeight.w300,
  );

  static const TextStyle subheading = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 16,
    height: 1.25,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle body1Bold = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle body1 = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle caption2 = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 10,
    height: 1.3,
    fontWeight: FontWeight.normal,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  static const TextStyle captionBold = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle button = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 14,
    height: 1,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle overLine = TextStyle(
    fontFamily: appFontFamily,
    fontSize: 10,
    height: 1.4,
    fontWeight: FontWeight.w400,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );
}
