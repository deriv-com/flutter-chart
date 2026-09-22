import 'package:flutter/material.dart';

/// Painting and hit-testing style for the draggable Accumulators barrier grips.
///
/// This lives on [AccumulatorBarrierDragController] rather than on [ChartTheme]
/// because the theme is a pure interface — adding a getter to it would break
/// every app that implements it — and because the annotation itself is rebuilt
/// on every tick.
@immutable
class AccumulatorBarrierGripStyle {
  /// Initializes the style of the barrier grips.
  const AccumulatorBarrierGripStyle({
    this.size = const Size(31, 12),
    this.borderRadius = 8,
    this.fillColor = const Color(0xFFF6F7F8),
    this.borderWidth = 1,
    this.innerLineCount = 2,
    this.innerLineInset = 4,
    this.innerLineSpacing = 3,
    this.lineWidth = 1,
    this.highlightLineWidth = 2,
    this.bandOpacity = 0.08,
    this.highlightBandOpacity = 0.16,
    this.mouseHitTolerance = 6,
    this.touchHitTolerance = 12,
    this.minTouchTarget = const Size(44, 44),
    this.cursor = SystemMouseCursors.resizeRow,
  });

  /// Painted size of a grip.
  final Size size;

  /// Corner radius of a grip.
  final double borderRadius;

  /// Grip background colour.
  final Color fillColor;

  /// Stroke width of the grip outline. The colour follows the barrier colour.
  final double borderWidth;

  /// Number of horizontal lines drawn inside a grip.
  final int innerLineCount;

  /// Horizontal inset of the inner lines from the grip edges.
  final double innerLineInset;

  /// Vertical spacing between the inner lines.
  final double innerLineSpacing;

  /// Stroke width of the barrier lines when idle.
  final double lineWidth;

  /// Stroke width of the barrier lines while hovered or dragged.
  final double highlightLineWidth;

  /// Opacity of the band fill when idle.
  final double bandOpacity;

  /// Opacity of the band fill while hovered or dragged.
  final double highlightBandOpacity;

  /// Vertical distance from a barrier line that still counts as a hit for a
  /// mouse pointer.
  final double mouseHitTolerance;

  /// Vertical distance from a barrier line that still counts as a hit for a
  /// touch pointer.
  final double touchHitTolerance;

  /// Minimum size a grip's hit rectangle is inflated to, so small grips stay
  /// reachable on touch devices.
  final Size minTouchTarget;

  /// Cursor shown while a barrier or grip is hovered.
  final MouseCursor cursor;

  /// Creates a copy of this style with the given fields replaced.
  AccumulatorBarrierGripStyle copyWith({
    Size? size,
    double? borderRadius,
    Color? fillColor,
    double? borderWidth,
    int? innerLineCount,
    double? innerLineInset,
    double? innerLineSpacing,
    double? lineWidth,
    double? highlightLineWidth,
    double? bandOpacity,
    double? highlightBandOpacity,
    double? mouseHitTolerance,
    double? touchHitTolerance,
    Size? minTouchTarget,
    MouseCursor? cursor,
  }) =>
      AccumulatorBarrierGripStyle(
        size: size ?? this.size,
        borderRadius: borderRadius ?? this.borderRadius,
        fillColor: fillColor ?? this.fillColor,
        borderWidth: borderWidth ?? this.borderWidth,
        innerLineCount: innerLineCount ?? this.innerLineCount,
        innerLineInset: innerLineInset ?? this.innerLineInset,
        innerLineSpacing: innerLineSpacing ?? this.innerLineSpacing,
        lineWidth: lineWidth ?? this.lineWidth,
        highlightLineWidth: highlightLineWidth ?? this.highlightLineWidth,
        bandOpacity: bandOpacity ?? this.bandOpacity,
        highlightBandOpacity: highlightBandOpacity ?? this.highlightBandOpacity,
        mouseHitTolerance: mouseHitTolerance ?? this.mouseHitTolerance,
        touchHitTolerance: touchHitTolerance ?? this.touchHitTolerance,
        minTouchTarget: minTouchTarget ?? this.minTouchTarget,
        cursor: cursor ?? this.cursor,
      );
}
