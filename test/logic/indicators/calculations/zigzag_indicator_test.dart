import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/ema_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/zigzag_indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ZigZag Indicator', () {
    List<Tick> ticks;

    setUpAll(() {
      ticks = const <Tick>[
        Tick(epoch: 1, quote: 64.75),
        Tick(epoch: 2, quote: 65.79),
        Tick(epoch: 3, quote: 64.73),
        Tick(epoch: 4, quote: 64.73),
        Tick(epoch: 5, quote: 65.55),
        Tick(epoch: 6, quote: 66.59),
        Tick(epoch: 7, quote: 63.61),
        Tick(epoch: 8, quote: 63.65),
        Tick(epoch: 9, quote: 62.15),
        Tick(epoch: 10, quote: 63.37),
        Tick(epoch: 11, quote: 61.33),
        Tick(epoch: 12, quote: 62.51),
      ];
    });

    test('ZigZagIndicator calculates the correct results', () {
      final ZigZagIndicator indicator =
          ZigZagIndicator(CloseValueIndicator(ticks), 1);

      expect(indicator.getValue(0).quote.isNaN, true);
      expect(indicator.getValue(1).quote, 65.79);
      expect(indicator.getValue(2).quote.isNaN, true);
      expect(indicator.getValue(3).quote.isNaN, true);
      expect(indicator.getValue(5).quote, 66.59);
      expect(indicator.getValue(7).quote.isNaN, true);
      expect(indicator.getValue(10).quote, 61.33);
      expect(indicator.getValue(11).quote, 62.51);
    });
  });
}
