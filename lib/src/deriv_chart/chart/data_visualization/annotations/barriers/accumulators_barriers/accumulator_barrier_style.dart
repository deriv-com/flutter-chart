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
    this.tapGuideLabelBackgroundColor = const Color(0xFF383D4A),
    this.tapGuideLabelStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
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

  /// Fill behind the tap hint's label.
  ///
  /// A fixed slate rather than the barrier's own colour: the label is a chip
  /// over the chart, and tinting it with the band would leave it competing with
  /// the band for the same reading.
  final Color tapGuideLabelBackgroundColor;

  /// Type for the tap hint's label.
  ///
  /// Deliberately without a `height`: the font's own metrics leave the glyphs
  /// room for their ascenders and descenders, and a forced line height would
  /// either clip the `j` in "adjust" or pad the pill by an amount the padding
  /// constants cannot see.
  final TextStyle tapGuideLabelStyle;

  /// Creates a copy of this style with the given fields replaced.
  AccumulatorBarrierStyle copyWith({
    double? lineWidth,
    double? highlightLineWidth,
    double? bandOpacity,
    double? highlightBandOpacity,
    double? mouseHitTolerance,
    double? touchHitTolerance,
    MouseCursor? cursor,
    Color? tapGuideLabelBackgroundColor,
    TextStyle? tapGuideLabelStyle,
  }) =>
      AccumulatorBarrierStyle(
        lineWidth: lineWidth ?? this.lineWidth,
        highlightLineWidth: highlightLineWidth ?? this.highlightLineWidth,
        bandOpacity: bandOpacity ?? this.bandOpacity,
        highlightBandOpacity: highlightBandOpacity ?? this.highlightBandOpacity,
        mouseHitTolerance: mouseHitTolerance ?? this.mouseHitTolerance,
        touchHitTolerance: touchHitTolerance ?? this.touchHitTolerance,
        cursor: cursor ?? this.cursor,
        tapGuideLabelBackgroundColor:
            tapGuideLabelBackgroundColor ?? this.tapGuideLabelBackgroundColor,
        tapGuideLabelStyle: tapGuideLabelStyle ?? this.tapGuideLabelStyle,
      );
}
