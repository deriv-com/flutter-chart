import 'package:flutter/material.dart';
import 'marker.dart';

/// Focused marker on the chart.
// ignore: must_be_immutable
class ActiveMarker extends Marker {
  /// Creates an active marker of given direction.
  ActiveMarker({
    required int epoch,
    required double quote,
    required MarkerDirection direction,
    required this.text,
    VoidCallback? onTap,
    this.onTapOutside,
  }) : super(
          epoch: epoch,
          quote: quote,
          direction: direction,
          onTap: onTap,
        );

  /// Text displayed on the marker.
  final String text;

  /// Called when chart is tapped outside of active marker.
  final VoidCallback? onTapOutside;
}
