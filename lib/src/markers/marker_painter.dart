import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/markers/marker.dart';
import 'package:flutter/material.dart';

import '../logic/chart_data.dart';
import 'marker_series.dart';
import 'paint_marker.dart';

/// A [SeriesPainter] for painting [MarkerPainter] data.
class MarkerPainter extends SeriesPainter<MarkerSeries> {
  /// Initializes
  MarkerPainter(MarkerSeries series) : super(series);

  @override
  void onPaint({
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  }) {
    for (final Marker marker in series.visibleEntries) {
      final Offset center = Offset(
        epochToX(marker.epoch),
        quoteToY(marker.quote),
      );
      final Offset anchor = center;

      paintMarker(
        canvas,
        center,
        anchor,
        series.markerRadius,
        marker.direction,
        series.style,
      );

      // Update marker tap area.
      marker.tapArea = Rect.fromCenter(
        center: center,
        width: series.markerRadius * 2,
        height: series.markerRadius * 2,
      ).inflate(12);
    }
  }
}
