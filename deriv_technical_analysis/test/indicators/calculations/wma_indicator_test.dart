import 'package:deriv_technical_analysis/src/helpers/functions.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/wma_indicator.dart';
import 'package:deriv_technical_analysis/src/models/tick.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Weighted Moving Average', () {
    List<Tick> ticks;

    setUpAll(() {
      ticks = const <Tick>[
        Tick(epoch: 1, quote: 1),
        Tick(epoch: 1, quote: 2),
        Tick(epoch: 1, quote: 3),
        Tick(epoch: 1, quote: 4),
        Tick(epoch: 1, quote: 5),
        Tick(epoch: 1, quote: 6),
      ];
    });

    test('WMAIndicator calculates the correct results', () {
      final WMAIndicator wmaIndicator =
          WMAIndicator(CloseValueIndicator(ticks), 3);

      expect(wmaIndicator.getValue(0).quote, 1);
      expect(roundDouble(wmaIndicator.getValue(1).quote, 4), 1.6667);
      expect(roundDouble(wmaIndicator.getValue(2).quote, 4), 2.3333);
      expect(roundDouble(wmaIndicator.getValue(3).quote, 4), 3.3333);
      expect(roundDouble(wmaIndicator.getValue(4).quote, 4), 4.3333);
      expect(roundDouble(wmaIndicator.getValue(5).quote, 4), 5.3333);
    });
  });
}
