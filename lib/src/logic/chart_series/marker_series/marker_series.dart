import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/marker.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';
import 'package:flutter/material.dart';

import 'marker_painter.dart';

/// Marker series
class MarkerSeries extends DataSeries<Marker> {
  /// Initializes
  MarkerSeries(
    List<Marker> entries, {
    String id,
    MarkerStyle style,
  }) : super(entries, id, style: style ?? const MarkerStyle());

  /// Tappable areas of visible markers.
  List<Rect> tapAreas = <Rect>[];

  @override
  SeriesPainter<MarkerSeries> createPainter() => MarkerPainter(this);

  @override
  Widget getCrossHairInfo(Marker crossHairTick, int pipSize) => null;

  @override
  double maxValueOf(Marker t) => t.quote;

  @override
  double minValueOf(Marker t) => t.quote;
}
