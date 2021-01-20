import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/statistics/variance_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VarianceIndicator', () {
    List<Tick> ticks;

    setUpAll(() {
      ticks = const <Tick>[
        Candle(epoch: 1, open: 64.75, close: 64.12, high: 67.5, low: 63),
        Candle(epoch: 2, open: 73.5, close: 74.62, high: 75.65, low: 73.12),
        Candle(epoch: 3, open: 74.2, close: 73.42, high: 76.3, low: 73.33),
        Candle(epoch: 4, open: 70.12, close: 72.2, high: 73.5, low: 70.12),
        Candle(epoch: 5, open: 73.21, close: 73.64, high: 76.3, low: 72.31),
      ];
    });

    test(
        'VarianceIndicator calculates the correct result from CloseValueIndicator..',
        () {
      final VarianceIndicator indicator =
          VarianceIndicator(CloseValueIndicator(ticks), 5);

      expect(roundDouble(indicator.getValue(1).quote, 4), 27.5625);
      expect(roundDouble(indicator.getValue(2).quote, 4), 22.02);
      expect(roundDouble(indicator.getValue(3).quote, 4), 16.9257);
      expect(roundDouble(indicator.getValue(4).quote, 4), 14.581);
    });
  });
}
