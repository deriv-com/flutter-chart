import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_entry_exit_marker.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

import 'marker.dart';
import 'marker_icon_painters/marker_icon_painter.dart';
import 'marker_series.dart';

/// A [SeriesPainter] for painting [MarkerPainter] data.
class MarkerPainter extends SeriesPainter<MarkerSeries> {
  /// Initializes
  MarkerPainter(MarkerSeries series, this.markerIconPainter) : super(series);

  /// Marker painter which is based on trade type
  final MarkerIconPainter markerIconPainter;

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
      paintEntryExitMarker(
        canvas,
        center,
        style.entryMarkerStyle,
      );
    }

    if (series.exitTick != null) {
      final Offset center = Offset(
        epochToX(series.exitTick!.epoch),
        quoteToY(series.exitTick!.quote),
      );
      paintEntryExitMarker(canvas, center, style.exitMarkerStyle);
    }

    for (final Marker marker in series.visibleEntries) {
      final Offset center = Offset(
        epochToX(marker.epoch),
        quoteToY(marker.quote),
      );
      final Offset anchor = center;

      markerIconPainter.paintMarker(
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

  @override
  List<CustomPainterSemantics> buildSemantics({
    required Size size,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
  }) {
    return <CustomPainterSemantics>[];
  }
}
