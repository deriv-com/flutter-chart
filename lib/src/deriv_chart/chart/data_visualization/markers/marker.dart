import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

/// Directions in which marker can face.
enum MarkerDirection {
  /// Point up.
  up,

  /// Point down.
  down,
}

/// Chart open position marker.
// ignore: must_be_immutable
class Marker extends Tick implements Comparable<Marker> {
  /// Creates a marker of given direction.
  Marker({
    required int epoch,
    required double quote,
    required this.direction,
    this.onTap,
  }) : super(epoch: epoch, quote: quote);

  /// Creates an up marker.
  Marker.up({
    required int epoch,
    required double quote,
    this.onTap,
  })  : direction = MarkerDirection.up,
        super(epoch: epoch, quote: quote);

  /// Creates a down marker.
  Marker.down({
    required int epoch,
    required double quote,
    this.onTap,
  })  : direction = MarkerDirection.down,
        super(epoch: epoch, quote: quote);

  /// Direction in which marker is facing.
  final MarkerDirection direction;

  /// Called when marker is tapped.
  final VoidCallback? onTap;

  /// Used to store marker tap area on the chart.
  late Rect tapArea;

  @override
  String toString() => 'Marker(epoch: $epoch, quote: $quote)';

  @override
  int compareTo(covariant Marker other) => epoch.compareTo(other.epoch);
}
