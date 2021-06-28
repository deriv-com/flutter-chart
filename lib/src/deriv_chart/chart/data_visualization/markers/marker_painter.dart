import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_entry_marker.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_exit_marker.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

import '../chart_data.dart';
import 'marker.dart';
import 'marker_series.dart';
import 'paint_marker.dart';

/// A [SeriesPainter] for painting [MarkerPainter] data.
class MarkerPainter extends SeriesPainter<MarkerSeries> {
  /// Initializes
  MarkerPainter(MarkerSeries series) : super(series);

  @override
  void onPaint({
    required Canvas canvas,
    required Size size,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
    required AnimationInfo animationInfo,
  }) {
    final MarkerStyle style = series.style as MarkerStyle? ?? theme.markerStyle;

    if (series.entryTick != null) {
      final Offset center = Offset(
        epochToX(series.entryTick!.epoch),
        quoteToY(series.entryTick!.quote),
      );
      paintEntryMarker(
        canvas,
        center,
        style.entryMarkerStyle,
        theme.base08Color,
      );
    }

    if (series.exitTick != null) {
      final Offset center = Offset(
        epochToX(series.exitTick!.epoch),
        quoteToY(series.exitTick!.quote),
      );
      paintExitMarker(canvas, center, style.exitMarkerStyle);
    }

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
        marker.direction,
        style,
      );

      // Update marker tap area.
      marker.tapArea = Rect.fromCenter(
        center: center,
        width: style.radius * 2,
        height: style.radius * 2,
      );
    }
  }
}
