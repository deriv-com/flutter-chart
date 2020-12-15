import 'package:meta/meta.dart';

@immutable
/// Tick class
class Tick {
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
  bool operator ==(covariant Tick other) =>
      epoch == other.epoch && quote == other.quote;

  @override
  int get hashCode => super.hashCode;
}
