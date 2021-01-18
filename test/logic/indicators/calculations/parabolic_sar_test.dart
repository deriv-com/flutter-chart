import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/parabolic_sar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ParabolicSarIndicator calculates the correct results', () {
    final List<Candle> bars = <Candle>[
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
      Candle.noParam(21, 0, 76.850000, 77, 76.190000),
    ];

    final ParabolicSarIndicator sar = ParabolicSarIndicator(bars);

    expect(sar.getValue(0).quote, isNaN);
    expect(roundDouble(sar.getValue(1).quote, 12), 74.640000000000);
    // start with up trend
    expect(roundDouble(sar.getValue(2).quote, 12), 74.640000000000);
    // switch to downtrend
    expect(roundDouble(sar.getValue(3).quote, 12), 76.269900000000);
    // hold trend...
    expect(roundDouble(sar.getValue(4).quote, 12), 76.234502000000);
    expect(roundDouble(sar.getValue(5).quote, 12), 76.200611960000);
    expect(roundDouble(sar.getValue(6).quote, 12), 76.112987481600);
    expect(roundDouble(sar.getValue(7).quote, 12), 75.958968232704);
    expect(roundDouble(sar.getValue(8).quote, 12), 75.699850774088);
    // switch to up trend
    expect(roundDouble(sar.getValue(9).quote, 12), 75.461462712161);
    // hold trend
    expect(roundDouble(sar.getValue(10).quote, 12), 72.720000000000);
    expect(roundDouble(sar.getValue(11).quote, 12), 72.802200000000);
    expect(roundDouble(sar.getValue(12).quote, 12), 72.964112000000);
    expect(roundDouble(sar.getValue(13).quote, 12), 73.203865280000);
    expect(roundDouble(sar.getValue(14).quote, 12), 73.513156057600);
    expect(roundDouble(sar.getValue(15).quote, 12), 73.797703572992);
    expect(roundDouble(sar.getValue(16).quote, 12), 74.059487287153);
    expect(roundDouble(sar.getValue(17).quote, 12), 74.300328304180);
    expect(roundDouble(sar.getValue(18).quote, 12), 74.521902039846);
    expect(roundDouble(sar.getValue(19).quote, 12), 74.725749876658);
    expect(roundDouble(sar.getValue(20).quote, 12), 74.913289886526);
  });
}
