export 'candle.dart';
export 'tick.dart';

abstract class DataPoint {
  int epoch;
  double quote;

  DataPoint(this.epoch, this.quote);
}
