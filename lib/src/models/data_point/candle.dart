import 'data_point.dart';

class Candle extends DataPoint {
  final double high;
  final double low;
  final double open;
  double get close => quote;

  Candle({
    int epoch,
    this.high,
    this.low,
    this.open,
    double close,
  }) : super(epoch, close);

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
}
