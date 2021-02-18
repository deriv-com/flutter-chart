import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/ohlc4_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mock_models.dart';

void main() {
  group('Testing OHLC/4 indicators', () {
    List<MockOHLC> ticks;

    setUpAll(() {
      ticks = const <MockOHLC>[
        MockOHLC.withNames(
            epoch: 1, open: 64.75, close: 64.12, high: 67.5, low: 63),
        MockOHLC.withNames(
            epoch: 2, open: 73.5, close: 74.62, high: 75.65, low: 73.12),
        MockOHLC.withNames(
            epoch: 3, open: 74.2, close: 73.42, high: 76.3, low: 73.33),
      ];
    });

    test('OHLC4Indicator calculates the correct results', () {
      final OHLC4Indicator<MockResult> indicator =
          OHLC4Indicator<MockResult>(MockInput(ticks));

      expect(indicator.getValue(0).quote, 64.8425);
      expect(indicator.getValue(1).quote, 74.2225);
      expect(indicator.getValue(2).quote, 74.3125);
    });
  });
}
