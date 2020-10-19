import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/marker.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

import 'marker_painter.dart';

/// Marker series
class MarkerSeries extends Series {
  /// Initializes
  MarkerSeries(
    List<Marker> entries, {
    String id,
    MarkerStyle style,
    this.markerSize = const Size.square(24),
  })  : _entries = entries,
        super(id, style: style ?? const MarkerStyle());

  /// Marker entries.
  final List<Marker> _entries;

  /// Visible marker entries.
  List<Marker> visibleEntries = <Marker>[];

  /// Size of a single marker.
  final Size markerSize;

  /// Tappable areas of visible markers.
  List<Rect> tapAreas = <Rect>[];

  @override
  SeriesPainter<MarkerSeries> createPainter() => MarkerPainter(this);

  @override
  void didUpdate(ChartData oldData) {}

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {}

  @override
  List<double> recalculateMinMax() {}
}
