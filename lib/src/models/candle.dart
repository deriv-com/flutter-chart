import 'package:deriv_chart/src/models/tick.dart';
import 'package:meta/meta.dart';

class Candle extends Tick {
  final int epoch;
  final double high;
  final double low;
  final double open;
  final double close;

  Candle({
    @required this.epoch,
    @required this.high,
    @required this.low,
    @required this.open,
    @required this.close,
  }) : super(epoch: epoch, quote: close);

  Candle copyWith({
    int epoch,
    double high,
    double low,
    double open,
    double close,
  }) {
    return Candle(
      epoch: epoch ?? this.epoch,
      high: high ?? this.high,
      low: low ?? this.low,
      open: open ?? this.open,
      close: close ?? this.close,
    );
  }

  @override
  String toString() =>
      'Candle(epoch: $epoch, high: $high, low: $low, open: $open, close: $close)';
}
