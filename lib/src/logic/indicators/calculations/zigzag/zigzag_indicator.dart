import 'dart:math';

import 'package:deriv_chart/src/models/tick.dart';

import '../../cached_indicator.dart';
import '../../indicator.dart';


/// Highest value in a range
class ZigZagIndicator extends CachedIndicator {
  /// Initializes
  ZigZagIndicator(this.indicator, this.distance)
      : super.fromIndicator(indicator);

  /// Calculating highest value on the result of this indicator
  final Indicator indicator;

  /// The period
  final int distance;

  @override
  Tick calculate(int index) {
    var x = indicator
        .getValue(index);
    var f = x.close * (distance / 10000);
    if (index == 0|| index==indicator.entries.length-1) {
      return x;
    }
    var j=Tick(epoch: x.epoch, quote: double.nan);
    for (int i = index + 1; i < indicator.entries.length; i++) {
      var element = indicator.getValue(i);
      if ((element.close - x.close).abs()>= f) {
        j=element;
        break;
      }
    }
    return j;
  }
}
