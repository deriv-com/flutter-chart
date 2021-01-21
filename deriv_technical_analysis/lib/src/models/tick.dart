import 'package:flutter/foundation.dart';

import 'ohlc.dart';

/// Basic data entry.
@immutable
class Tick implements OHLC {
  /// Initializes
  const Tick({
    @required this.epoch,
    @required this.quote,
  });

  @override
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
