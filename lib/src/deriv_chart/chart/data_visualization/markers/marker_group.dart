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
  /// @param currentEpoch The current epoch timestamp, used for dynamic progress calculations.
  MarkerGroup(
    this.markers, {
    required this.type,
    this.id,
    this.props = const MarkerProps(),
    this.style = const MarkerStyle(
      activeMarkerText: TextStyle(
        color: Colors.black,
        fontSize: 12,
        height: 1.4,
      ),
    ),
    this.currentEpoch,
    this.profitAndLossText,
    this.isProfit = true,
    this.onTap,
  });

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

  /// The current epoch timestamp, used for dynamic progress calculations.
  /// This value represents the last tick epoch and is used by marker painters
  /// to calculate progress animations, expiration states, and other time-dependent
  /// visual effects. For example, contract markers can use this to show
  /// the remaining duration as an animated progress arc.
  final int? currentEpoch;

  /// The text to display in the profit and loss label.
  final String? profitAndLossText;

  /// Whether the contract for the marker group is in profit or loss.
  ///
  /// This is used to determine the color of the profit and loss label.
  final bool isProfit;

  /// Callback when the circular contract marker of the marker group is tapped.
  final VoidCallback? onTap;

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
