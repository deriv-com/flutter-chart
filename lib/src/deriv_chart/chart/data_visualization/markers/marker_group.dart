import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_props.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/chart_marker.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

/// Chart open position marker.
/// MarkerGroup is a container class that organizes related chart markers into a logical unit.
///
/// It serves as a grouping mechanism for ChartMarker objects that are related to each other
/// and should be treated as a cohesive unit on the chart. For example, a MarkerGroup might
/// represent all markers related to a specific trade or contract, such as entry points,
/// exit points, barriers, and ticks.
///
/// Each MarkerGroup has a specific type (e.g., "tick", "digit", "accumulator") that determines
/// how its markers are rendered on the chart. Different types of marker groups are rendered
/// by specialized MarkerGroupIconPainter implementations.
///
/// MarkerGroups can be sorted based on the epoch of their first marker, which is useful
/// for determining the order in which they should be displayed or processed.
///
/// The MarkerGroup class is used by MarkerGroupSeries to organize and display groups of
/// related markers on a chart. The MarkerGroupPainter class is responsible for painting
/// these marker groups on the canvas.
class MarkerGroup implements Comparable<MarkerGroup> {
  /// Initialize marker group with a list of related markers and additional properties.
  ///
  /// @param markers A list of ChartMarker objects that belong to this group.
  /// @param type The type of marker group, which determines how it's rendered.
  /// @param id An optional identifier for the marker group.
  /// @param props Additional properties that can affect rendering behavior.
  /// @param style The visual style to apply to markers in this group.
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

  /// The list of ChartMarker objects that belong to this group.
  /// These markers are related to each other and are treated as a cohesive unit.
  final List<ChartMarker> markers;

  /// An optional identifier for the marker group.
  /// This can be used to reference or look up specific marker groups.
  final String? id;

  /// The visual style to apply to markers in this group.
  /// This includes properties like colors, fonts, and sizes.
  final MarkerStyle style;

  /// The type of marker group, which determines how it's rendered.
  /// Different types of marker groups are handled by specialized MarkerGroupIconPainter
  /// implementations, such as TickMarkerIconPainter, DigitMarkerIconPainter, etc.
  final String type;

  /// Additional properties that can affect rendering behavior.
  /// For example, the hasPersistentBorders property determines whether
  /// barriers should be drawn even when they're outside the visible area.
  final MarkerProps props;

  /// Compares this marker group with another based on the epoch of their first markers.
  /// This is useful for sorting marker groups chronologically.
  @override
  int compareTo(covariant MarkerGroup other) {
    final int epoch = markers.isNotEmpty ? markers.first.epoch : 0;
    final int otherEpoch =
        other.markers.isNotEmpty ? other.markers.first.epoch : 0;
    return epoch.compareTo(otherEpoch);
  }
}
