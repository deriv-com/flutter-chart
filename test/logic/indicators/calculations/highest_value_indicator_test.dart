import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/highest_value_indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Highest value indicator test', () {
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
        Tick(epoch: 11, quote: 66.37),
        Tick(epoch: 12, quote: 68.51),
      ];
    });

    test('HighestValueIndicator calculates the correct results', () {
      final HighestValueIndicator indicator =
          HighestValueIndicator(CloseValueIndicator(ticks), 10);

      expect(roundDouble(indicator.results[9].quote, 4), 64.75);
      expect(roundDouble(indicator.results[10].quote, 4), 66.37);
      expect(roundDouble(indicator.results[11].quote, 4), 68.51);
    });
  });
}
