import 'package:meta/meta.dart';

class Candle {
  Candle({
    @required this.epoch,
    @required this.high,
    @required this.low,
    @required this.open,
    @required this.close,
  });

  final int epoch;
  final double high;
  final double low;
  final double open;
  final double close;
}
