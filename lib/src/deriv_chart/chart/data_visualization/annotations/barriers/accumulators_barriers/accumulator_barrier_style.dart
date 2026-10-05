import 'package:flutter/material.dart';

/// Painting and hit-testing style for the interactive Accumulators band.
///
/// This lives on [AccumulatorBarrierController] rather than on [ChartTheme]
/// because the theme is a pure interface — adding a getter to it would break
/// every app that implements it — and because the annotation itself is rebuilt
/// on every tick.
@immutable
class AccumulatorBarrierStyle {
  /// Initializes the style of the interactive band.
  const AccumulatorBarrierStyle({
    this.lineWidth = 1,
    this.highlightLineWidth = 2,
    this.bandOpacity = 0.08,
    this.highlightBandOpacity = 0.16,
    this.mouseHitTolerance = 6,
    this.touchHitTolerance = 12,
    this.cursor = SystemMouseCursors.click,
  });

  /// Stroke width of the barrier lines when idle.
  final double lineWidth;

  /// Stroke width of the barrier lines while the band is hovered.
  final double highlightLineWidth;

  /// Opacity of the band fill when idle.
  final double bandOpacity;

  /// Opacity of the band fill while the band is hovered.
  final double highlightBandOpacity;

  /// Margin beyond a barrier line that still counts as the band for a mouse
  /// pointer, so the edges are easy to hit.
  final double mouseHitTolerance;

  /// The same margin for a touch pointer, which is far less precise.
  final double touchHitTolerance;

  /// Cursor shown while the band is hovered.
  final MouseCursor cursor;

  /// Creates a copy of this style with the given fields replaced.
  AccumulatorBarrierStyle copyWith({
    double? lineWidth,
    double? highlightLineWidth,
    double? bandOpacity,
    double? highlightBandOpacity,
    double? mouseHitTolerance,
    double? touchHitTolerance,
    MouseCursor? cursor,
  }) =>
      AccumulatorBarrierStyle(
        lineWidth: lineWidth ?? this.lineWidth,
        highlightLineWidth: highlightLineWidth ?? this.highlightLineWidth,
        bandOpacity: bandOpacity ?? this.bandOpacity,
        highlightBandOpacity: highlightBandOpacity ?? this.highlightBandOpacity,
        mouseHitTolerance: mouseHitTolerance ?? this.mouseHitTolerance,
        touchHitTolerance: touchHitTolerance ?? this.touchHitTolerance,
        cursor: cursor ?? this.cursor,
      );
}
