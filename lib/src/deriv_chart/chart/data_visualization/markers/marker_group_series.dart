import 'dart:collection';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/chart_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_group.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_group_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_icon_painters/marker_group_icon_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_series.dart';

/// Marker Group series
///
/// A specialized series for displaying groups of related markers on a chart.
/// This class extends [MarkerSeries] and provides functionality for managing
/// and displaying collections of [MarkerGroup] objects.
///
/// MarkerGroupSeries is responsible for determining which marker groups should be
/// visible based on the current chart viewport (defined by leftEpoch and rightEpoch).
class MarkerGroupSeries extends MarkerSeries {
  /// Initializes a new instance of the MarkerGroupSeries class.
  ///
  /// @param entries A SplayTreeSet of Marker objects that this series will manage
  /// @param markerGroupIconPainter The painter responsible for rendering marker group icons
  /// @param markerGroupList An optional list of MarkerGroup objects to be displayed
  MarkerGroupSeries(
    SplayTreeSet<Marker> entries, {
    required this.markerGroupIconPainter,
    this.markerGroupList,
  }) : super(entries, markerIconPainter: markerGroupIconPainter);

  /// Painter that draws corresponding marker icons.
  ///
  /// This painter is responsible for rendering the visual representation
  /// of marker groups on the chart canvas.
  final MarkerGroupIconPainter markerGroupIconPainter;

  /// List of related grouped markers.
  ///
  /// This list contains all the marker groups that this series manages.
  /// Each MarkerGroup contains a collection of related ChartMarker objects.
  final List<MarkerGroup>? markerGroupList;

  /// List of marker groups that are currently visible in the chart viewport.
  ///
  /// This list is updated by the [onUpdate] method whenever the chart's
  /// viewport changes. It contains only the marker groups that should be
  /// visible based on the current viewport boundaries.
  List<MarkerGroup> visibleMarkerGroupList = <MarkerGroup>[];

  @override

  /// Creates a painter for rendering this marker group series on the chart.
  ///
  /// This method returns a [MarkerGroupPainter] that is responsible for
  /// drawing the marker groups on the chart canvas. The painter uses the
  /// [visibleMarkerGroupList] to determine which marker groups to render.
  ///
  /// @return A SeriesPainter that can render this marker group series
  SeriesPainter<MarkerGroupSeries> createPainter() {
    return MarkerGroupPainter(
      this,
      markerGroupIconPainter,
    );
  }

  @override

  /// Updates the list of visible marker groups based on the current chart viewport.
  ///
  /// This method is called whenever the chart's viewport changes (e.g., due to
  /// scrolling or zooming). It filters the [markerGroupList] to determine which
  /// marker groups should be visible based on the current viewport boundaries.
  ///
  /// A marker group is considered visible if:
  /// 1. It has at least one marker ([group.markers.isNotEmpty])
  /// 2. Its last (latest) marker is not completely to the left of the viewport
  ///    ([group.markers.last.epoch >= leftEpoch])
  /// 3. Its first (earliest) marker is not completely to the right of the viewport
  ///    ([group.markers.first.epoch <= rightEpoch])
  /// 4. OR it contains a contractMarker (which should always be visible)
  ///
  /// This ensures that marker groups are only visible if they have at least one
  /// marker within the viewport or spanning across the viewport boundaries.
  /// Special handling is provided for contractMarkers which are always visible.
  ///
  /// @param leftEpoch The epoch (timestamp) at the left edge of the visible chart area
  /// @param rightEpoch The epoch (timestamp) at the right edge of the visible chart area
  void onUpdate(int leftEpoch, int rightEpoch) {
    if (markerGroupList != null) {
      visibleMarkerGroupList = markerGroupList!.where(
        (MarkerGroup group) {
          if (group.markers.isEmpty) {
            return false;
          }

          // Always keep groups with contractMarker visible
          final bool hasContractMarker = group.markers.any(
            (marker) => marker.markerType == MarkerType.contractMarker,
          );

          if (hasContractMarker) {
            return true;
          }

          // Apply normal epoch-based filtering for other groups
          return group.markers.last.epoch >= leftEpoch &&
              group.markers.first.epoch <= rightEpoch;
        },
      ).toList();
    } else {
      visibleMarkerGroupList = <MarkerGroup>[];
    }
  }
}
