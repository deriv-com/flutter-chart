import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Basic data entry.
@immutable
class Tick with EquatableMixin {
  /// Initializes
  const Tick({
    @required this.epoch,
    @required this.quote,
  });

  /// Epoch of the tick
  final int epoch;

  /// Tick price
  final double quote;

  @override
  List<Object> get props => [epoch, quote];
}
