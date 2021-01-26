import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/open_value_indicator.dart';
import 'package:deriv_technical_analysis/src/models/candle.dart';
import 'package:deriv_technical_analysis/src/models/tick.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Testing open value indicators', () {
    List<Tick> ticks;

    setUpAll(() {
      ticks = const <Tick>[
        Candle(epoch: 1, open: 64.75, close: 64.12, high: 67.5, low: 63),
        Candle(epoch: 2, open: 73.5, close: 74.62, high: 75.65, low: 73.12),
        Candle(epoch: 3, open: 74.2, close: 73.42, high: 76.3, low: 73.33),
      ];
    });

    test('OpenValueIndicator calculates the correct results', () {
      final OpenValueIndicator indicator = OpenValueIndicator(ticks);

      expect(indicator.getValue(0).quote, 64.75);
      expect(indicator.getValue(1).quote, 73.5);
      expect(indicator.getValue(2).quote, 74.2);
    });
  });
}
