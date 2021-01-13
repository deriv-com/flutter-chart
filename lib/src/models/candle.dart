import 'package:deriv_chart/src/logic/min_max_calculator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Candle class
@immutable
class Candle extends Tick with EquatableMixin implements MinMaxCalculatorEntry {
  /// Initializes
  const Candle({
    @required int epoch,
    @required this.high,
    @required this.low,
    @required this.open,
    @required this.close,
  }) : super(epoch: epoch, quote: close);

  Candle.noParam(int epoch, double open, double close, double high, double low)
      : this(epoch: epoch, open: open, close: close, high: high, low: low);

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
  String toString() =>
      'Candle(epoch: $epoch, high: $high, low: $low, open: $open, close: $close)';

  List<Object> get props => [epoch, open, close, high, low];

  @override
  double get min => low;

  @override
  double get max => high;
}
