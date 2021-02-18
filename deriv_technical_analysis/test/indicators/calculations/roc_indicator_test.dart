import 'package:deriv_technical_analysis/src/helpers/functions.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/roc_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock_models.dart';

void main() {
  group('Price Rate Of Change Indicator', () {
    List<MockTick> ticks;

    setUpAll(() {
      ticks = const <MockTick>[
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
    });

    test('ROCIndicator calculates the correct results', () {
      final CloseValueIndicator<MockResult> closeValueIndicator =
          CloseValueIndicator<MockResult>(MockInput(ticks));
      final ROCIndicator<MockResult> rocIndicator =
          ROCIndicator<MockResult>.fromIndicator(closeValueIndicator, 2);

      expect(rocIndicator.getValue(0).quote, 0);
      expect(rocIndicator.getValue(3).quote, 100);
      expect(roundDouble(rocIndicator.getValue(10).quote, 2), 33.33);
      expect(rocIndicator.getValue(12).quote, -50);
    });
  });
}
