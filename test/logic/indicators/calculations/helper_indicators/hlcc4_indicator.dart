import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/hlcc4_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Testing HLCC/4 indicators', () {
    List<Tick> ticks;

    setUpAll(() {
      ticks = <Tick>[
        Candle(epoch: 1, open: 64.75, close: 64.12, high: 67.5, low: 63),
        Candle(epoch: 2, open: 73.5, close: 74.62, high: 75.65, low: 73.12),
        Candle(epoch: 3, open: 74.2, close: 73.42, high: 76.3, low: 73.33),
      ];
    });

    test('HLCC4Indicator calculates the correct results', () {
      final HLCC4Indicator indicator = HLCC4Indicator(ticks);

      expect(indicator.getValue(0).quote, 64.685);
      expect(indicator.getValue(1).quote, 74.5025);
      expect(indicator.getValue(2).quote, 74.1175);
    });
  });
}
