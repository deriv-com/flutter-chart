import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_group.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_group_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker_icon_painters/marker_group_icon_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';

/// A [SeriesPainter] for painting [MarkerGroupPainter] data.
class MarkerGroupPainter extends SeriesPainter<MarkerGroupSeries> {
  /// Initializes
  MarkerGroupPainter(MarkerGroupSeries series, this.markerGroupIconPainter)
      : super(series);

  /// Marker painter which is based on trade type
  final MarkerGroupIconPainter markerGroupIconPainter;

  @override
  void onPaint({
    required Canvas canvas,
    required Size size,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
    required AnimationInfo animationInfo,
    required ChartScaleModel chartScaleModel,
  }) {
    // Get PainterProps directly from the model
    final props = chartScaleModel.toPainterProps();

    for (final MarkerGroup markerGroup in series.visibleMarkerGroupList) {
      markerGroupIconPainter.paintMarkerGroup(
        canvas,
        size,
        theme,
        markerGroup,
        epochToX,
        quoteToY,
        props,
      );
    }
  }
}
