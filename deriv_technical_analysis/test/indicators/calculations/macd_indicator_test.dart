import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/macd_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<Tick> ticks;

  setUpAll(() {
    ticks = const <Tick>[
      Tick(epoch: 00, quote: 80.854),
      Tick(epoch: 01, quote: 80.850),
      Tick(epoch: 02, quote: 80.854),
      Tick(epoch: 03, quote: 80.844),
      Tick(epoch: 04, quote: 80.843),
      Tick(epoch: 05, quote: 80.837),
      Tick(epoch: 06, quote: 80.839),
      Tick(epoch: 07, quote: 80.844),
      Tick(epoch: 08, quote: 80.853),
      Tick(epoch: 09, quote: 80.842),
      Tick(epoch: 10, quote: 80.836),
      Tick(epoch: 11, quote: 80.832),
      Tick(epoch: 12, quote: 80.833),
      Tick(epoch: 13, quote: 80.833),
      Tick(epoch: 14, quote: 80.832),
      Tick(epoch: 15, quote: 80.836),
      Tick(epoch: 16, quote: 80.833),
      Tick(epoch: 17, quote: 80.839),
      Tick(epoch: 18, quote: 80.841),
      Tick(epoch: 19, quote: 80.845),
      Tick(epoch: 20, quote: 80.855),
      Tick(epoch: 21, quote: 80.843),
      Tick(epoch: 22, quote: 80.843),
      Tick(epoch: 23, quote: 80.846),
      Tick(epoch: 24, quote: 80.842),
      Tick(epoch: 25, quote: 80.840),
      Tick(epoch: 26, quote: 80.846),
    ];
  });

  group(' Moving Average Convergance Divergence Indicator tests', () {
    test(
        ' Moving Average Convergance Divergence Indicator shoud calculate the correct result from the given closed value indicator ticks.',
        () {
      final CloseValueIndicator closeValueIndicator =
          CloseValueIndicator(ticks);

      final MACDIndicator macdIndicator =
          MACDIndicator.fromIndicator(closeValueIndicator);
      // expect(macdIndicator.getValue(26).quote, 0.0011);
    });
  });
}
