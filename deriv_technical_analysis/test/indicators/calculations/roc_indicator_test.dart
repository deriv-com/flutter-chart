import 'package:deriv_technical_analysis/src/helpers/functions.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/roc_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock_models.dart';

void main() {
  group('Price Rate Of Change Indicator', () {
    test('ROCIndicator should calculates the correct results', () {
      const List<MockTick> ticks = <MockTick>[
        MockTick(epoch: 0, quote: 1),
        MockTick(epoch: 1, quote: 2),
        MockTick(epoch: 2, quote: 3),
        MockTick(epoch: 3, quote: 4),
        MockTick(epoch: 4, quote: 3),
        MockTick(epoch: 5, quote: 4),
        MockTick(epoch: 6, quote: 5),
        MockTick(epoch: 7, quote: 4),
        MockTick(epoch: 8, quote: 3),
        MockTick(epoch: 9, quote: 3),
        MockTick(epoch: 10, quote: 4),
        MockTick(epoch: 11, quote: 3),
        MockTick(epoch: 12, quote: 2),
      ];

      final CloseValueIndicator<MockResult> closeValueIndicator =
          CloseValueIndicator<MockResult>(MockInput(ticks));
      final ROCIndicator<MockResult> rocIndicator =
          ROCIndicator<MockResult>.fromIndicator(closeValueIndicator, 2);

      expect(rocIndicator.getValue(0).quote, 0);
      expect(rocIndicator.getValue(3).quote, 100);
      expect(roundDouble(rocIndicator.getValue(10).quote, 2), 33.33);
      expect(rocIndicator.getValue(12).quote, -50);
    });
    test('ROCIndicator with TA4j data  should calculates the correct results',
        () {
      const List<MockTick> ticks = <MockTick>[
        MockTick(epoch: 0, quote: 11045.27),
        MockTick(epoch: 1, quote: 11167.32),
        MockTick(epoch: 2, quote: 11008.61),
        MockTick(epoch: 3, quote: 11151.83),
        MockTick(epoch: 4, quote: 10926.77),
        MockTick(epoch: 5, quote: 10868.12),
        MockTick(epoch: 6, quote: 10520.32),
        MockTick(epoch: 7, quote: 10380.43),
        MockTick(epoch: 8, quote: 10785.14),
        MockTick(epoch: 9, quote: 10748.26),
        MockTick(epoch: 10, quote: 10896.91),
        MockTick(epoch: 11, quote: 10782.95),
        MockTick(epoch: 12, quote: 10620.16),
        MockTick(epoch: 13, quote: 10625.83),
        MockTick(epoch: 14, quote: 10510.95),
        MockTick(epoch: 15, quote: 10444.37),
        MockTick(epoch: 16, quote: 10068.01),
        MockTick(epoch: 17, quote: 10193.39),
        MockTick(epoch: 18, quote: 10066.57),
        MockTick(epoch: 19, quote: 10043.75),
      ];

      final CloseValueIndicator<MockResult> closeValueIndicator =
          CloseValueIndicator<MockResult>(MockInput(ticks));
      final ROCIndicator<MockResult> rocIndicator =
          ROCIndicator<MockResult>.fromIndicator(closeValueIndicator, 12);

      expect(roundDouble(rocIndicator.getValue(0).quote, 4), 0);
      expect(roundDouble(rocIndicator.getValue(1).quote, 4), 1.105);
      expect(roundDouble(rocIndicator.getValue(2).quote, 4), -0.3319);
      expect(roundDouble(rocIndicator.getValue(3).quote, 4), 0.9648);
    });
  });
}
