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
    this.activeMarker,
    this.entryTick,
    this.exitTick,
  })  : _entries = entries.toList(),
        super(id, style: style);

  /// Marker entries.
  final List<Marker> _entries;

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
  // TODO(Ramin): Return correct result,
  // We only use the result of didUpdate of the mainSeries for now to whether play the new tick animation or not,
  // No need to check if the marker series data has changed with chart update.
  bool didUpdate(ChartData oldData) => false;

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
