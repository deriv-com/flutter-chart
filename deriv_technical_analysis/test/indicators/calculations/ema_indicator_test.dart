import 'package:deriv_technical_analysis/src/helpers/functions.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/ema_indicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock_models.dart';

void main() {
  group('Exponential Moving Average', () {
    List<MockTick> ticks;

    setUpAll(() {
      ticks = const <MockTick>[
        MockTick(epoch: 1, quote: 64.75),
        MockTick(epoch: 2, quote: 63.79),
        MockTick(epoch: 3, quote: 63.73),
        MockTick(epoch: 4, quote: 63.73),
        MockTick(epoch: 5, quote: 63.55),
        MockTick(epoch: 6, quote: 63.19),
        MockTick(epoch: 7, quote: 63.91),
        MockTick(epoch: 8, quote: 63.85),
        MockTick(epoch: 9, quote: 62.95),
        MockTick(epoch: 10, quote: 63.37),
        MockTick(epoch: 11, quote: 61.33),
        MockTick(epoch: 12, quote: 61.51),
      ];
    });

    test('EMAIndicator calculates the correct results', () {
      final EMAIndicator<MockResult> indicator = EMAIndicator<MockResult>(
        CloseValueIndicator<MockResult>(MockInput(ticks)),
        10,
      );

      expect(roundDouble(indicator.results[9].quote, 4), 63.6948);
      expect(roundDouble(indicator.results[10].quote, 4), 63.2649);
      expect(roundDouble(indicator.results[11].quote, 4), 62.9458);
    });
  });
}
