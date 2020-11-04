import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:flutter/material.dart';

import '../chart_data.dart';

// TODO(ramin): We need to eventually remove quoteLabelAreaWidth and use textPainter's width instead
/// Overall horizontal padding for current tick indicator quote label
const double quoteLabelHorizontalPadding = 10;

/// A class responsible to paint its [series] data.
abstract class SeriesPainter<S extends Series> {
  /// Initializes series for sub-class
  SeriesPainter(this.series);

  /// The [Series] which this [SeriesPainter] belongs to
  final S series;

  /// Chart's config
  @protected
  ChartConfig chartConfig;

  /// Sets some variables and paints this [SeriesPainter]'s data
  void paint({
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    ChartConfig chartConfig,
  }) {
    this.chartConfig = chartConfig;

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
