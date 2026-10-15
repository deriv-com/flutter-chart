import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The on-canvas geometry of the Accumulators barriers, as resolved by
/// [AccumulatorIndicatorPainter] for the frame it last painted.
///
/// The painter publishes this so the interaction overlay can hit-test against
/// the pixels the user actually sees. Recomputing the positions in the overlay
/// would disagree with the painter for the duration of the post-tick lerp.
@immutable
class AccumulatorBarrierGeometry {
  /// Initializes the resolved barrier geometry.
  const AccumulatorBarrierGeometry({
    required this.barrierX,
    required this.rightEdgeX,
    required this.highBarrierY,
    required this.lowBarrierY,
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

  /// Half-width of the *committed* band in quote units, i.e. the distance the
  /// model (not any preview) currently places each barrier from the spot.
  ///
  /// What a preview glides away from when it starts.
  final double committedBarrierSpotDistance;

  /// Whether [offset] falls on the band: anywhere between the two barriers,
  /// plus [tolerance] beyond each line so the edges stay easy to hit.
  ///
  /// This is the tap target. It does not care which barrier is nearer — a tap
  /// opens the consumer's control, which is what moves the band.
  bool containsBand(Offset offset, {required double tolerance}) {
    final bool withinX =
        offset.dx >= barrierX - tolerance && offset.dx <= rightEdgeX;
    if (!withinX) {
      return false;
    }

    // Not assumed to be ordered: the painter resolves them from quotes, and a
    // flipped pair would otherwise make the band untappable.
    final double top = math.min(highBarrierY, lowBarrierY) - tolerance;
    final double bottom = math.max(highBarrierY, lowBarrierY) + tolerance;

    return offset.dy >= top && offset.dy <= bottom;
  }
}
