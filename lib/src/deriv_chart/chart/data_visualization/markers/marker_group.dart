import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_props.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/web_marker.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

/// Chart open position marker.
class MarkerGroup implements Comparable<MarkerGroup> {
  /// Initialize marker group
  MarkerGroup(
    this.markers, {
    required this.type,
    this.id,
    Map<String, dynamic>? props,
    this.style = const MarkerStyle(
      activeMarkerText: TextStyle(
        color: Colors.black,
        fontSize: 12,
        height: 1.4,
      ),
    ),
  }) : props = MarkerProps.fromMap(props);

  /// Marker entries.
  final List<WebMarker> markers;

  /// Marker group id.
  final String? id;

  /// The `MarkerStyle` to paint the markers.
  final MarkerStyle style;

  /// Marker group type.
  final String type;

  /// Extra props for the marker group
  final MarkerProps props;

  @override
  int compareTo(covariant MarkerGroup other) {
    final int epoch = markers.isNotEmpty ? markers.first.epoch : 0;
    final int otherEpoch =
        other.markers.isNotEmpty ? other.markers.first.epoch : 0;
    return epoch.compareTo(otherEpoch);
  }
}
