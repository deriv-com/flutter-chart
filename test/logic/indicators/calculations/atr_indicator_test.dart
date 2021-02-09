import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/atr_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<Tick> ticks;

  setUpAll(() {
    ticks = const <Tick>[
      Candle.noParam(00, 79.537, 79.532, 79.540, 79.520),
      Candle.noParam(01, 79.532, 79.524, 79.530, 79.520),
      Candle.noParam(02, 79.523, 79.526, 79.530, 79.520),
      Candle.noParam(03, 79.525, 79.529, 79.530, 79.520),
      Candle.noParam(04, 79.528, 79.532, 79.530, 79.510),
      Candle.noParam(05, 79.533, 79.525, 79.530, 79.510),
      Candle.noParam(06, 79.525, 79.514, 79.520, 79.500),
      Candle.noParam(07, 79.515, 79.510, 79.510, 79.500),
      Candle.noParam(08, 79.509, 79.507, 79.510, 79.500),
      Candle.noParam(09, 79.507, 79.518, 79.520, 79.500),
    ];
  });

  group('ATR Indicator test', () {
    test(
        'ATR Indicator should calculate the correct result from the given ticks and period.',
        () {
      final ATRIndicator fivePeriodIndicator = ATRIndicator(ticks, period: 5);
      final ATRIndicator tenPeriodIndicator = ATRIndicator(ticks, period: 10);

      expect(roundDouble(fivePeriodIndicator.getValue(4).quote, 3), 0.016);
      expect(roundDouble(tenPeriodIndicator.getValue(9).quote, 3), 0.017);
    });
  });
}
