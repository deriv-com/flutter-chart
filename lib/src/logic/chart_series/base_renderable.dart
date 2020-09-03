import 'dart:math';

import 'package:deriv_chart/src/logic/chart_series/base_series.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:flutter/material.dart';

/// Base class for Renderables which has a list of entries to paint
/// entries called [visibleEntries] inside the [paint] method
abstract class BaseRendererable {
  /// Initializes
  BaseRendererable(
    this.series,
    this.visibleEntries,
    this.leftEpoch,
    this.rightEpoch,
  );

  /// Visible entries of [series] inside the frame
  final List<Candle> visibleEntries;

  /// The [BaseSeries] which this renderable belongs to
  final BaseSeries series;

  /// Left epoch
  final int leftEpoch;

  /// Right epoch
  final int rightEpoch;

  int startIndex = 0;
  int endIndex = 1;

  /// Paints [entries] on the [canvas]
  void paint({
    Canvas canvas,
    Size size,
    double animatingMinValue,
    double animatingMaxValue,
    Candle prevLastEntry,
  }) {
    if (visibleEntries.isEmpty) {
      return;
    }
    onPaint(
      canvas: canvas,
      size: size,
      prevLastEntry: prevLastEntry,
    );
  }

  /// Paints [visibleEntries] based on the [animatingMaxValue] [_animatingMinValue]
  void onPaint({
    Canvas canvas,
    Size size,
    Candle prevLastEntry,
  });
}
