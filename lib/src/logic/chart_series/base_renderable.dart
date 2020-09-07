import 'package:deriv_chart/src/logic/chart_series/base_series.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

typedef EpochToX = double Function(int);
typedef QuoteToY = double Function(double);

/// Base class for Renderables which has a list of entries to paint
/// entries called [visibleEntries] inside the [paint] method
abstract class BaseRendererable<T extends Tick> {
  /// Initializes
  BaseRendererable(
    this.series,
    this.visibleEntries,
    this.prevLastEntry,
  );

  /// Visible entries of [series] inside the frame
  final List<T> visibleEntries;

  /// Previous last entry
  final T prevLastEntry;

  /// The [BaseSeries] which this renderable belongs to
  final BaseSeries<T> series;

  /// Paints [visibleEntries] on the [canvas]
  void paint({
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  }) {
    if (visibleEntries.isEmpty) {
      return;
    }
    onPaint(
      canvas: canvas,
      size: size,
      epochToX: epochToX,
      quoteToY: quoteToY,
      animationInfo: animationInfo,
    );

    if (series.style.currentTickStyle != null) {
    // TODO(ramin): paint current tick indicator

    }
  }

  /// Paints [visibleEntries] based on the [animatingMaxValue] [_animatingMinValue]
  void onPaint({
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  });
}
