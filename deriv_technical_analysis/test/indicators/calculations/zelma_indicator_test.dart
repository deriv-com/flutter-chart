import 'package:deriv_technical_analysis/src/helpers/functions.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/zelma_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock_models.dart';

void main() {
  group('Zero-lag Exponential Moving Average', () {
    List<MockTick> ticks;

    setUpAll(() {
      ticks = const <MockTick>[
        MockTick(epoch: 1, quote: 10),
        MockTick(epoch: 1, quote: 15),
        MockTick(epoch: 1, quote: 20),
        MockTick(epoch: 1, quote: 18),
        MockTick(epoch: 1, quote: 17),
        MockTick(epoch: 1, quote: 18),
        MockTick(epoch: 1, quote: 15),
        MockTick(epoch: 1, quote: 12),
        MockTick(epoch: 1, quote: 10),
        MockTick(epoch: 1, quote: 8),
        MockTick(epoch: 1, quote: 5),
        MockTick(epoch: 1, quote: 2),
      ];
    });

    test('ZLEMAIndicator calculates the correct results', () {
      final ZLEMAIndicator<MockResult> indicator = ZLEMAIndicator<MockResult>(
        CloseValueIndicator<MockResult>(MockInput(ticks)),
        10,
      );

      expect(roundDouble(indicator.results[9].quote, 3), 11.909);
      expect(roundDouble(indicator.results[10].quote, 4), 8.8347);
      expect(roundDouble(indicator.results[11].quote, 4), 5.7739);
    });
  });
}
