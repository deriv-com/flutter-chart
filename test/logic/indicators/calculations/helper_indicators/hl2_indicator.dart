import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/hl2_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Testing HL/2 indicators', () {
    List<Tick> ticks;

    setUpAll(() {
      ticks = <Tick>[
        Candle(epoch: 1, open: 64.75, close: 64.12, high: 67.5, low: 63),
        Candle(epoch: 2, open: 73.5, close: 74.62, high: 75.65, low: 73.12),
        Candle(epoch: 3, open: 74.2, close: 73.42, high: 76.3, low: 73.33),
      ];
    });

    test('HL2Indicator calculates the correct results', () {
      final HL2Indicator indicator = HL2Indicator(ticks);

      expect(indicator.getValue(0).quote, 65.25);
      expect(indicator.getValue(1).quote, 74.385);
      expect(indicator.getValue(2).quote, 74.815);
    });
  });
}