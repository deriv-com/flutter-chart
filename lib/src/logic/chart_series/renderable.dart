import 'dart:ui';

import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/paint/paint_current_tick_dot.dart';
import 'package:deriv_chart/src/paint/paint_current_tick_label.dart';
import 'package:deriv_chart/src/theme/painting_styles/current_tick_style.dart';
import 'package:flutter/material.dart';

import '../chart_data.dart';

// TODO(ramin): We need to eventually remove quoteLabelAreaWidth and use textPainter's width instead
/// Overall horizontal padding for current tick indicator quote label
const double quoteLabelHorizontalPadding = 10;

/// Base class for Renderables which has a list of entries to paint
/// entries called [Series.visibleEntries] inside the [paint] method
abstract class Rendererable<S extends Series> {
  /// Initializes series for sub-class
  Rendererable(this.series);

  /// The [Series] which this renderable belongs to
  final S series;

  /// Number of decimal digits in showing prices.
  @protected
  int pipSize;

  /// Duration of a candle in ms or (time difference between two ticks).
  @protected
  int granularity;

  /// Paints [Series.visibleEntries] on the [canvas]
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

  /// Paints [Series.visibleEntries]
  void onPaint({
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  });
}
