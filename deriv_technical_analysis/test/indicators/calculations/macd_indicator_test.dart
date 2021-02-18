import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:deriv_technical_analysis/src/helpers/functions.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/macd_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock_models.dart';

void main() {
  List<MockTick> ticks;

  setUpAll(() {
    ticks = const <MockTick>[
      MockTick(epoch: 00, quote: 82.201),
      MockTick(epoch: 02, quote: 82.200),
      MockTick(epoch: 03, quote: 82.200),
      MockTick(epoch: 04, quote: 82.200),
      MockTick(epoch: 05, quote: 82.200),
      MockTick(epoch: 06, quote: 82.201),
      MockTick(epoch: 07, quote: 82.198),
      MockTick(epoch: 08, quote: 82.198),
      MockTick(epoch: 09, quote: 82.199),
      MockTick(epoch: 10, quote: 82.199),
      MockTick(epoch: 11, quote: 82.199),
      MockTick(epoch: 12, quote: 82.198),
      MockTick(epoch: 13, quote: 82.196),
      MockTick(epoch: 14, quote: 82.197),
      MockTick(epoch: 15, quote: 82.194),
      MockTick(epoch: 16, quote: 82.195),
      MockTick(epoch: 17, quote: 82.194),
      MockTick(epoch: 18, quote: 82.194),
      MockTick(epoch: 19, quote: 82.194),
      MockTick(epoch: 20, quote: 82.195),
      MockTick(epoch: 21, quote: 82.195),
      MockTick(epoch: 22, quote: 82.195),
      MockTick(epoch: 23, quote: 82.194),
      MockTick(epoch: 24, quote: 82.194),
      MockTick(epoch: 25, quote: 82.192),
      MockTick(epoch: 26, quote: 82.192),
      MockTick(epoch: 27, quote: 82.192),
      MockTick(epoch: 28, quote: 82.191),
      MockTick(epoch: 29, quote: 82.188),
      MockTick(epoch: 30, quote: 82.189),
      MockTick(epoch: 31, quote: 82.192),
      MockTick(epoch: 32, quote: 82.192),
      MockTick(epoch: 33, quote: 82.193),
      MockTick(epoch: 34, quote: 82.193),
      MockTick(epoch: 35, quote: 82.192),
      MockTick(epoch: 36, quote: 82.193),
      MockTick(epoch: 37, quote: 82.193),
      MockTick(epoch: 38, quote: 82.192),
      MockTick(epoch: 39, quote: 82.192),
    ];
  });

  group(' Moving Average Convergance Divergence Indicator tests', () {
    test(
        ' Moving Average Convergance Divergence Indicator shoud calculate the correct result from the given closed value indicator ticks.',
        () {
      final CloseValueIndicator<MockResult> closeValueIndicator =
          CloseValueIndicator<MockResult>(MockInput(ticks));

      final MACDIndicator<MockResult> macdIndicator =
          MACDIndicator<MockResult>.fromIndicator(closeValueIndicator);
      expect(roundDouble(macdIndicator.getValue(36).quote, 4), -0.0012);
      expect(roundDouble(macdIndicator.getValue(37).quote, 4), -0.0011);
      expect(roundDouble(macdIndicator.getValue(38).quote, 4), -0.0011);
    });
  });
}
