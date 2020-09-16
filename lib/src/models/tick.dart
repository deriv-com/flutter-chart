import 'package:deriv_chart/src/models/chart_object.dart';
import 'package:meta/meta.dart';

class Tick implements ChartObject{
  Tick({
    @required this.epoch,
    @required this.quote,
  });

  final int epoch;
  final double quote;

  @override
  int get leftEpoch => epoch;

  @override
  int get rightEpoch => epoch;

}
