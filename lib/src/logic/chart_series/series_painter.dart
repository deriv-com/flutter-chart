import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:flutter/material.dart';

import '../chart_data.dart';

/// A class responsible to paint its [series] data.
abstract class SeriesPainter<S extends Series> {
  /// Initializes series for sub-class
  SeriesPainter(this.series);

  /// The [Series] which this [SeriesPainter] belongs to
  final S series;

  /// Number of decimal digits in showing prices.
  @protected
  int pipSize;

  /// Duration of a candle in ms or (time difference between two ticks).
  @protected
  int granularity;

  /// Sets some variables and paints this [SeriesPainter]'s data
  void paint({
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    int pipSize,
    int granularity,
  }) {
    this.pipSize = pipSize;
    this.granularity = granularity;

    onPaint(
      canvas: canvas,
      size: size,
      epochToX: epochToX,
      quoteToY: quoteToY,
      animationInfo: animationInfo,
    );
  }

  /// Paints this [SeriesPainter]'s data
  void onPaint({
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  });
}
