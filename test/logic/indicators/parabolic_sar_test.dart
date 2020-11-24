import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/parabolic_sar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Parabolic SAR test', () {
    List<Candle> bars = <Candle>[
      Candle.noParam(1, 0, 75.1, 74.06, 75.11),
      Candle.noParam(2, 0, 75.9, 76.030000, 74.640000),
      Candle.noParam(3, 0, 75.24, 76.269900, 75.060000),
      Candle.noParam(4, 0, 75.17, 75.280000, 74.500000),
      Candle.noParam(5, 0, 74.6, 75.310000, 74.540000),
      Candle.noParam(6, 0, 74.1, 75.467000, 74.010000),
      Candle.noParam(7, 0, 73.740000, 74.700000, 73.546000),
      Candle.noParam(8, 0, 73.390000, 73.830000, 72.720000),
      Candle.noParam(9, 0, 73.25, 73.890000, 72.86),
      Candle.noParam(10, 0, 74.36, 74.410000, 73),
      Candle.noParam(11, 0, 76.510000, 76.830000, 74.820000),
      Candle.noParam(12, 0, 75.590000, 76.850000, 74.540000),
      Candle.noParam(13, 0, 75.910000, 76.960000, 75.510000),
      Candle.noParam(14, 0, 74.610000, 77.070000, 74.560000),
      Candle.noParam(15, 0, 75.330000, 75.530000, 74.010000),
      Candle.noParam(16, 0, 75.010000, 75.500000, 74.510000),
      Candle.noParam(17, 0, 75.620000, 76.210000, 75.250000),
      Candle.noParam(18, 0, 76.040000, 76.460000, 75.092800),
      Candle.noParam(19, 0, 76.450000, 76.450000, 75.435000),
      Candle.noParam(20, 0, 76.260000, 76.470000, 75.840000),
      Candle.noParam(21, 0, 76.850000, 77.000000, 76.190000),
    ];

    ParabolicSarIndicator sar = new ParabolicSarIndicator(bars);


    for (int i = 0; i < bars.length; i++) {
      final result = sar.getValue(i);
    }

    // assertEquals("NaN", sar.getValue(0).toString());
    // assertNumEquals(74.640000000000000568434188608080, sar.getValue(1));
    // assertNumEquals(74.640000000000000568434188608080, sar.getValue(2)); // start with up trend
    // assertNumEquals(76.269900000000006912159733474255, sar.getValue(3)); // switch to downtrend
    // assertNumEquals(76.234502000000006773916538804770, sar.getValue(4)); // hold trend...
    // assertNumEquals(76.200611960000006763493729522452, sar.getValue(5));
    // assertNumEquals(76.112987481600006697590288240463, sar.getValue(6));
    // assertNumEquals(75.958968232704006684543855953962, sar.getValue(7));
    // assertNumEquals(75.699850774087686058830877300352, sar.getValue(8));
    // assertNumEquals(75.461462712160671083174936939031, sar.getValue(9)); // switch to up trend
    // assertNumEquals(72.719999999999998863131622783840, sar.getValue(10));// hold trend
    // assertNumEquals(72.802199999999998851762939011678, sar.getValue(11));
    // assertNumEquals(72.964111999999998670318746007979, sar.getValue(12));
    // assertNumEquals(73.203865279999998374933056766167, sar.getValue(13));
    // assertNumEquals(73.513156057599997959241591161117, sar.getValue(14));
    // assertNumEquals(73.797703572991997576805442804471, sar.getValue(15));
    // assertNumEquals(74.059487287152637224964186316356, sar.getValue(16));
    // assertNumEquals(74.300328304180425701270230347291, sar.getValue(17));
    // assertNumEquals(74.521902039845991099471790855751, sar.getValue(18));
    // assertNumEquals(74.725749876658311265817226523534, sar.getValue(19));
    // assertNumEquals(74.913289886525645818855027337894, sar.getValue(20));
  });
}
