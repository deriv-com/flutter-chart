import 'package:flutter/material.dart';
import 'marker.dart';

/// Focused marker on the chart.
// ignore: must_be_immutable
class ActiveMarker extends Marker {
  /// Creates an active marker of given direction.
  ActiveMarker(
      {required int epoch,
      required double quote,
      required MarkerDirection direction,
      required this.text,
      VoidCallback? onTap,
      this.onTapOutside,
      this.isRightLabeled = true})
      : super(
          epoch: epoch,
          quote: quote,
          direction: direction,
          onTap: onTap,
        );

  /// Text displayed on the marker.
  final String text;

  /// Called when chart is tapped outside of active marker.
  final VoidCallback? onTapOutside;

  /// Is label shown on the right side of the marker (regular side)
  /// for accumulators label should be shown on the left side.
  final bool isRightLabeled;
}
