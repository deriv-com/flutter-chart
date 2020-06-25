import 'data_point.dart';

class Tick extends DataPoint {
  Tick({
    int epoch,
    double quote,
  }) : super(epoch, quote);
}
