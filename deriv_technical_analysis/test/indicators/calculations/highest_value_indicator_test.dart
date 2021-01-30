import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/highest_value_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock_models.dart';

void main() {
  group('Highest value indicator test', () {
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
        MockTick(epoch: 10, quote: 61.37),
        MockTick(epoch: 11, quote: 66.37),
        MockTick(epoch: 12, quote: 68.51),
      ];
    });

    test('HighestValueIndicator calculates the correct results', () {
      final HighestValueIndicator<MockResult> indicator =
          HighestValueIndicator<MockResult>(
        CloseValueIndicator<MockResult>(MockInput(ticks)),
        10,
      );

      expect(indicator.results[9].quote, 64.75);
      expect(indicator.results[10].quote, 66.37);
      expect(indicator.results[11].quote, 68.51);
    });
  });
}
