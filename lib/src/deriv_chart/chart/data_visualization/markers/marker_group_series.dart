import 'dart:collection';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_group.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_group_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_icon_painters/marker_group_icon_painter.dart';
import 'package:deriv_chart/src/misc/wrapped_controller.dart';

/// Marker Group series
class MarkerGroupSeries extends MarkerSeries {
  /// Initializes.
  MarkerGroupSeries(
    SplayTreeSet<Marker> entries, {
    required this.markerGroupIconPainter,
    required this.controller,
    required this.yAxisWidth,
    required this.isMobile,
    required this.granularity,
    this.markerGroupList,
  }) : super(entries, markerIconPainter: markerGroupIconPainter);

  /// Painter that draw corresponding marker icon.
  final MarkerGroupIconPainter markerGroupIconPainter;

  /// List of related grouped markers.
  final List<MarkerGroup>? markerGroupList;

  /// WrappedController
  final WrappedController controller;

  /// The width of y-axis
  final double yAxisWidth;

  /// Whether it is in mobile mode or not.
  final bool isMobile;

  /// Granulatiry of the chart.
  final int granularity;

  /// Visible marker entries.
  List<MarkerGroup> visibleMarkerGroupList = <MarkerGroup>[];

  @override
  SeriesPainter<MarkerGroupSeries> createPainter() => MarkerGroupPainter(
        this,
        markerGroupIconPainter,
        controller: controller,
        yAxisWidth: yAxisWidth,
        isMobile: isMobile,
        granularity: granularity,
      );

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    if (markerGroupList != null) {
      visibleMarkerGroupList = markerGroupList!
          .where(
            (MarkerGroup group) =>
                group.markers.isNotEmpty &&
                group.markers.last.epoch >= leftEpoch,
          )
          .toList();
    } else {
      visibleMarkerGroupList = <MarkerGroup>[];
    }
  }
}
