import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'accumulator_barrier_grip_style.dart';
import 'accumulator_barrier_side.dart';

/// The on-canvas geometry of the Accumulators barriers, as resolved by
/// [AccumulatorIndicatorPainter] for the frame it last painted.
///
/// The painter publishes this so the drag overlay can hit-test against the
/// pixels the user actually sees. Recomputing the positions in the overlay
/// would disagree with the painter for the duration of the post-tick lerp.
@immutable
class AccumulatorBarrierGeometry {
  /// Initializes the resolved barrier geometry.
  const AccumulatorBarrierGeometry({
    required this.barrierX,
    required this.rightEdgeX,
    required this.highBarrierY,
    required this.lowBarrierY,
    required this.highGripRect,
    required this.lowGripRect,
    required this.bandCenterQuote,
    required this.committedBarrierSpotDistance,
  });

  /// X coordinate where the band starts (the barrier epoch).
  final double barrierX;

  /// X coordinate where the band ends.
  final double rightEdgeX;

  /// Y coordinate of the high barrier line.
  final double highBarrierY;

  /// Y coordinate of the low barrier line.
  final double lowBarrierY;

  /// Hit/paint rectangle of the high barrier's grip.
  final Rect highGripRect;

  /// Hit/paint rectangle of the low barrier's grip.
  final Rect lowGripRect;

  /// Quote at the vertical centre of the band.
  ///
  /// The drag maps a pointer position to a distance from this value.
  final double bandCenterQuote;

  /// Half-width of the *committed* band in quote units, i.e. the distance the
  /// model (not any preview) currently places each barrier from the spot.
  ///
  /// Used to detect that the model has moved in response to a commit.
  final double committedBarrierSpotDistance;

  /// Returns the barrier [offset] falls on, or `null` when it falls on neither.
  ///
  /// Grips win over lines, and the nearer barrier wins when both match.
  AccumulatorBarrierSide? hitTest(
    Offset offset, {
    required double lineTolerance,
    required Size minTouchTarget,
  }) {
    final Rect highGrip = _inflateToMinimum(highGripRect, minTouchTarget);
    final Rect lowGrip = _inflateToMinimum(lowGripRect, minTouchTarget);

    final bool onHighGrip = highGrip.contains(offset);
    final bool onLowGrip = lowGrip.contains(offset);

    if (onHighGrip && onLowGrip) {
      return _nearest(offset);
    }
    if (onHighGrip) {
      return AccumulatorBarrierSide.high;
    }
    if (onLowGrip) {
      return AccumulatorBarrierSide.low;
    }

    final bool withinBandX =
        offset.dx >= barrierX - lineTolerance && offset.dx <= rightEdgeX;
    if (!withinBandX) {
      return null;
    }

    final bool onHighLine = (offset.dy - highBarrierY).abs() <= lineTolerance;
    final bool onLowLine = (offset.dy - lowBarrierY).abs() <= lineTolerance;

    if (onHighLine && onLowLine) {
      return _nearest(offset);
    }
    if (onHighLine) {
      return AccumulatorBarrierSide.high;
    }
    if (onLowLine) {
      return AccumulatorBarrierSide.low;
    }

    return null;
  }

  /// Horizontal centre of a grip.
  ///
  /// Pinned near the right of the plotting area so a finger on a grip never
  /// covers the barrier value it is changing, and pushed back inside the band
  /// when the band is too narrow to hold the grip at that position.
  static double gripCenterX({
    required double barrierX,
    required double rightEdgeX,
    required AccumulatorBarrierGripStyle style,
  }) =>
      math.max(
        barrierX + style.size.width / 2,
        rightEdgeX - style.rightMargin - style.size.width / 2,
      );

  AccumulatorBarrierSide _nearest(Offset offset) =>
      (offset.dy - highBarrierY).abs() <= (offset.dy - lowBarrierY).abs()
          ? AccumulatorBarrierSide.high
          : AccumulatorBarrierSide.low;

  static Rect _inflateToMinimum(Rect rect, Size minimum) => Rect.fromCenter(
        center: rect.center,
        width: rect.width < minimum.width ? minimum.width : rect.width,
        height: rect.height < minimum.height ? minimum.height : rect.height,
      );
}
