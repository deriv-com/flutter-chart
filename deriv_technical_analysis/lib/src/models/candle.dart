import 'package:meta/meta.dart';

import 'tick.dart';

/// Candle class.
@immutable
class Candle extends Tick {
  /// Initializes a candle class.
  const Candle({
    @required int epoch,
    @required this.high,
    @required this.low,
    @required this.open,
    @required this.close,
  }) : super(epoch: epoch, quote: close);

  /// Initializes a candle class with only the given parameters or non given.
  const Candle.noParam(
      int epoch, double open, double close, double high, double low)
      : this(epoch: epoch, open: open, close: close, high: high, low: low);

  @override
  final double high;

  @override
  final double low;

  @override
  final double open;

  @override
  final double close;

  /// Creates a copy of this object.
  Candle copyWith({
    int epoch,
    double high,
    double low,
    double open,
    double close,
  }) =>
      Candle(
        epoch: epoch ?? this.epoch,
        high: high ?? this.high,
        low: low ?? this.low,
        open: open ?? this.open,
        close: close ?? this.close,
      );

  @override
  String toString() =>
      'Candle(epoch: $epoch, high: $high, low: $low, open: $open, close: $close)';

  // ignore_hash_and_equals
  @override
  bool operator ==(covariant Candle other) =>
      epoch == other.epoch &&
      open == other.open &&
      high == other.high &&
      low == other.low &&
      close == other.close;
}
