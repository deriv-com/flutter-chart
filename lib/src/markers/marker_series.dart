import 'dart:math' as math;
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/logic/find.dart';
import 'package:deriv_chart/src/markers/marker.dart';
import 'package:deriv_chart/src/markers/active_marker.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';

import 'marker_painter.dart';

/// Marker series
class MarkerSeries extends Series {
  /// Initializes
  MarkerSeries(
    List<Marker> entries, {
    String id,
    MarkerStyle style,
    this.activeMarker,
  })  : _entries = entries,
        super(id, style: style ?? const MarkerStyle());

  /// Marker entries.
  final List<Marker> _entries;

  /// Visible marker entries.
  List<Marker> visibleEntries = <Marker>[];

  /// Active/focused marker on the chart.
  final ActiveMarker activeMarker;

  @override
  SeriesPainter<MarkerSeries> createPainter() => MarkerPainter(this);

  @override
  void didUpdate(ChartData oldData) {}

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    if (_entries.isEmpty) {
      visibleEntries = <Marker>[];
      return;
    }

    final int left = findEpochIndex(leftEpoch, _entries).ceil();
    final int right = findEpochIndex(rightEpoch, _entries).floor();

    visibleEntries = _entries.sublist(left, right + 1);
  }

  @override
  List<double> recalculateMinMax() => <double>[double.nan, double.nan];
}
