import 'package:deriv_chart/src/models/tick.dart';
import 'package:meta/meta.dart';

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
  }) : super(epoch: epoch, quote: quote);

  /// Direction in which marker is facing.
  final MarkerDirection direction;

  @override
  String toString() => 'Marker(epoch: $epoch, quote: $quote)';
}
