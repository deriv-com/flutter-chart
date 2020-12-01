import 'package:meta/meta.dart';

import 'ohlc.dart';

class Tick implements OHLC {
  Tick({
    @required this.epoch,
    @required this.quote,
  });

  final int epoch;
  final double quote;

  @override
  double get close => quote;

  @override
  double get high => quote;

  @override
  double get low => quote;

  @override
  double get open => quote;
}
