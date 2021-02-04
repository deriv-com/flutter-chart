import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/lowest_value_indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Lowest value indicator test', () {
    List<Tick> ticks;

    setUpAll(() {
      ticks = <Tick>[
        Tick(epoch: 1, quote: 64.75),
        Tick(epoch: 2, quote: 63.79),
        Tick(epoch: 3, quote: 63.73),
        Tick(epoch: 4, quote: 63.73),
        Tick(epoch: 5, quote: 63.55),
        Tick(epoch: 6, quote: 63.19),
        Tick(epoch: 7, quote: 63.91),
        Tick(epoch: 8, quote: 63.85),
        Tick(epoch: 9, quote: 62.95),
        Tick(epoch: 10, quote: 61.37),
        Tick(epoch: 11, quote: 56.37),
        Tick(epoch: 12, quote: 48.51),
      ];
    });

    test('LowestValueIndicator calculates the correct results', () {
      final LowestValueIndicator indicator =
          LowestValueIndicator(CloseValueIndicator(ticks), 10);

      expect(indicator.getValue(9).quote, 61.37);
      expect(indicator.getValue(10).quote, 56.37);
      expect(indicator.getValue(11).quote, 48.51);
    });
  });
}
