import 'package:equatable/equatable.dart';

/// A class that holds epoch and yCoord of the edge points.
class EdgePoint with EquatableMixin {
  /// Initializes
  const EdgePoint({
    this.epoch = 0,
    this.quote = 0,
  });

  /// Epoch.
  final int epoch;

  /// Quote.
  final double quote;

  @override
  List<Object?> get props => <Object>[epoch, quote];
}
