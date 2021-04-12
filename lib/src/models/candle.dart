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
    @required this.currentEpochTime,
  }) : super(epoch: epoch, quote: close);

  /// Initializes a candle class with only the given parameters or non given.
  const Candle.noParam(int epoch, double open, double close, double high,
      double low, int currentEpochTime)
      : this(
          epoch: epoch,
          open: open,
          close: close,
          high: high,
          low: low,
          currentEpochTime: currentEpochTime,
        );

  /// High value
  @override
  final double high;

  /// Low value.
  @override
  final double low;

  /// Open value.
  @override
  final double open;

  /// Close value.
  @override
  final double close;

  /// The current time value of candle.
  final int currentEpochTime;

  /// Creates a copy of this object.
  Candle copyWith({
    int epoch,
    double high,
    double low,
    double open,
    double close,
    double currentEpochTime,
  }) =>
      Candle(
        epoch: epoch ?? this.epoch,
        high: high ?? this.high,
        low: low ?? this.low,
        open: open ?? this.open,
        close: close ?? this.close,
        currentEpochTime: currentEpochTime ?? this.currentEpochTime,
      );

  @override
  String toString() =>
      'Candle(epoch: $epoch, high: $high, low: $low, open: $open, close: $close, currentEpochTime: $currentEpochTime)';

  @override
  List<Object> get props => <Object>[
        epoch,
        open,
        close,
        high,
        low,
        currentEpochTime,
      ];
}
