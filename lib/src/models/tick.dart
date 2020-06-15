import 'package:meta/meta.dart';

class Tick {
  Tick({
    @required this.epoch,
    @required this.quote,
  });

  final int epoch;
  final double quote;
}
