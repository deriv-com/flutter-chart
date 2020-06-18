import 'package:meta/meta.dart';

class Candle {
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
  });

  Candle.tick({
    @required this.epoch,
    @required double quote,
  })  : high = quote,
        low = quote,
        open = quote,
        close = quote;

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
}
