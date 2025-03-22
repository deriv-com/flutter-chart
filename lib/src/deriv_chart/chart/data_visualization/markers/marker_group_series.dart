import 'dart:collection';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_group.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_group_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_icon_painters/marker_group_icon_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_series.dart';

/// Marker Group series
class MarkerGroupSeries extends MarkerSeries {
  /// Initializes.
  MarkerGroupSeries(
    SplayTreeSet<Marker> entries, {
    required this.markerGroupIconPainter,
    this.markerGroupList,
  }) : super(entries, markerIconPainter: markerGroupIconPainter);

  /// Painter that draw corresponding marker icon.
  final MarkerGroupIconPainter markerGroupIconPainter;

  /// List of related grouped markers.
  final List<MarkerGroup>? markerGroupList;

  /// Visible marker entries.
  List<MarkerGroup> visibleMarkerGroupList = <MarkerGroup>[];

  @override
  SeriesPainter<MarkerGroupSeries> createPainter() {
    return MarkerGroupPainter(
      this,
      markerGroupIconPainter,
    );
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    if (markerGroupList != null) {
      visibleMarkerGroupList = markerGroupList!
          .where(
            (MarkerGroup group) =>
                group.markers.isNotEmpty &&
                group.markers.last.epoch >= leftEpoch &&
                group.markers.first.epoch <= rightEpoch,
          )
          .toList();
    } else {
      visibleMarkerGroupList = <MarkerGroup>[];
    }
  }
}
