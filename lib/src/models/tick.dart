import 'package:meta/meta.dart';

import 'ohlc.dart';

/// Tick class
@immutable
class Tick implements OHLC {
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
  double get close => quote;

  @override
  double get high => quote;

  @override
  double get low => quote;

  @override
  double get open => quote;

  @override
  bool operator ==(covariant Tick other) =>
      epoch == other.epoch && quote == other.quote;

  @override
  int get hashCode => super.hashCode;
}
