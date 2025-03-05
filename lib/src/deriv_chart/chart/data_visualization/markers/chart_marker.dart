import 'package:flutter/material.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/markers/marker.dart';

/// Type of the marker.
enum MarkerType {
  /// Active start marker.
  activeStart,

  /// Start marker.
  start,

  /// Entry marker.
  entry,

  /// Entry marker tick.
  entryTick,

  /// Latest tick marker.
  latestTick,

  /// Previous tick marker.
  previousTick,

  /// Tick marker.
  tick,

  /// End marker.
  end,

  /// Exit marker.
  exit,

  /// Latest tick point on the barrier.
  latestTickBarrier,

  /// High Barrier.
  highBarrier,

  /// Low Barrier.
  lowBarrier,
}

/// Chart open position marker.
// ignore: must_be_immutable
class ChartMarker extends Marker {
  /// Initializes.
  ChartMarker({
    required int epoch,
    required double quote,
    required MarkerDirection direction,
    this.markerType,
    this.text,
    this.color,
  }) : super(epoch: epoch, quote: quote, direction: direction);

  /// Type of marker.
  final MarkerType? markerType;

  /// Text displayed on the marker.
  final String? text;

  /// Color of the marker
  final Color? color;
}
