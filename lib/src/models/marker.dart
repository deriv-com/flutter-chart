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
class Marker extends Tick {
  /// Creates a marker with given type, positioned at the given coordinate.
  Marker({
    @required this.direction,
    @required int epoch,
    @required double quote,
    this.onTap,
  }) : super(epoch: epoch, quote: quote);

  /// Direction in which marker is facing.
  final MarkerDirection direction;

  /// Called when marker is tapped.
  final VoidCallback onTap;

  @override
  String toString() => 'Marker(epoch: $epoch, quote: $quote)';
}
