import 'package:deriv_chart/src/models/tick.dart';
import 'package:meta/meta.dart';

/// Candle class
@immutable
class Candle extends Tick {
  /// Initializes
  const Candle({
    @required int epoch,
    @required this.high,
    @required this.low,
    @required this.open,
    @required this.close,
  }) : super(epoch: epoch, quote: close);

  /// High value
  final double high;

  /// low value
  final double low;

  /// open value
  final double open;

  /// close value
  final double close;

  /// Creates a copy of this object
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
  bool operator ==(covariant Candle other) =>
      epoch == other.epoch &&
      open == other.open &&
      high == other.high &&
      low == other.low &&
      close == other.close;

  @override
  String toString() =>
      'Candle(epoch: $epoch, high: $high, low: $low, open: $open, close: $close)';
}
