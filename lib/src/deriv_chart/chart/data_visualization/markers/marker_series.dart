import 'dart:collection';

import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/find.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/marker_style.dart';

import '../chart_data.dart';
import '../chart_series/series.dart';
import 'active_marker.dart';
import 'marker.dart';
import 'marker_icon_painters/marker_icon_painter.dart';
import 'marker_painter.dart';

/// Marker series
class MarkerSeries extends Series {
  /// Initializes.
  MarkerSeries(
    SplayTreeSet<Marker> entries, {
    required this.markerIconPainter,
    String? id,
    MarkerStyle? style,
    this.activeMarker,
    this.entryTick,
    this.exitTick,
  })  : _entries = entries.toList(),
        super(id ?? 'Markers', style: style);

  /// Marker entries.
  final List<Marker> _entries;

  /// Visible marker entries.
  List<Marker> visibleEntries = <Marker>[];

  /// Active/focused marker on the chart.
  final ActiveMarker? activeMarker;

  /// Entry tick marker.
  final Tick? entryTick;

  /// Exit tick marker.
  final Tick? exitTick;

  /// Painter that draw corresponding marker icon.
  final MarkerIconPainter markerIconPainter;

  @override
  SeriesPainter<MarkerSeries> createPainter() => MarkerPainter(
        this,
        markerIconPainter,
      );

  @override
  // TODO(Ramin): Return correct result,
  // We only use the result of didUpdate of the mainSeries for now to whether
  // play the new tick animation or not, No need to check if the marker series
  // data has changed with chart update.
  bool didUpdate(ChartData? oldData) => false;

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

  @override
  int? getMaxEpoch() => _entries.isNotEmpty ? _entries.last.epoch : null;

  @override
  int? getMinEpoch() => _entries.isNotEmpty ? _entries.first.epoch : null;
}
