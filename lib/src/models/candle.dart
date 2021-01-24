import 'package:deriv_chart/src/models/tick.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Candle class.
@immutable
class Candle extends Tick with EquatableMixin {
  /// Initializes a candle class.
  const Candle({
    @required int epoch,
    @required this.high,
    @required this.low,
    @required this.open,
    @required this.close,
  }) : super(epoch: epoch, quote: close);

  /// Initializes a candle class with only the given parameters or non given.
  Candle.noParam(int epoch, double open, double close, double high, double low)
      : this(epoch: epoch, open: open, close: close, high: high, low: low);

  /// High value
  final double high;

  /// Low value.
  final double low;

  /// Open value.
  final double open;

  /// Close value.
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

  List<Object> get props => [epoch, open, close, high, low];
}