import 'dart:collection';

import 'package:deriv_chart/deriv_chart.dart';
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
    SplayTreeSet<Marker> entries, {
    String id,
    MarkerStyle style,
    bool sortMarkersList = true,
    this.activeMarker,
    this.entryTick,
    this.exitTick,
  })  : _entries = entries,
        super(id, style: style);

  /// Marker entries.
  final SplayTreeSet<Marker> _entries;

  /// Visible marker entries.
  List<Marker> visibleEntries = <Marker>[];

  /// Active/focused marker on the chart.
  final ActiveMarker activeMarker;

  /// Entry tick marker.
  final Tick entryTick;

  /// Exit tick marker.
  final Tick exitTick;

  @override
  SeriesPainter<MarkerSeries> createPainter() => MarkerPainter(this);

  @override
  void didUpdate(ChartData oldData) {}

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    visibleEntries = <Marker>[];

    if (_entries.isEmpty) {
      return;
    }

    final int left = findEpochIndex(leftEpoch, _entries).ceil();
    final int right = findEpochIndex(rightEpoch, _entries).floor();

    for (int i = 0; i < _entries.length; i++) {
      if (i >= left && i <= right) {
        visibleEntries.add(_entries.elementAt(i));
      }
    }
  }

  @override
  List<double> recalculateMinMax() => <double>[double.nan, double.nan];
}
