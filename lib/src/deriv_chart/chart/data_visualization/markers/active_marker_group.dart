import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/chart_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_group.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_props.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

/// Active marker data bound to a marker group.
class ActiveMarkerGroup extends MarkerGroup {
  /// Creates an active marker group with the same parameters as an ActiveMarker,
  /// in addition to the base MarkerGroup configuration.
  ActiveMarkerGroup({
    // MarkerGroup parameters
    required List<ChartMarker> markers,
    required String type,
    required MarkerDirection direction,
    String? id,
    MarkerProps props = const MarkerProps(),
    MarkerStyle style = const MarkerStyle(
      activeMarkerText: TextStyle(
        color: Colors.black,
        fontSize: 12,
        height: 1.4,
      ),
    ),
    int? currentEpoch,
    String? profitAndLossText,
    VoidCallback? onTap,
    this.onTapOutside,
  }) : super(
          markers,
          type: type,
          direction: direction,
          id: id,
          props: props,
          style: style,
          currentEpoch: currentEpoch,
          profitAndLossText: profitAndLossText,
          onTap: onTap,
        );

  /// Called when a tap occurs outside the active marker group.
  final VoidCallback? onTapOutside;
}
