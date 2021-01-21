import 'package:deriv_technical_analysis/src/helpers/functions.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/ema_indicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_technical_analysis/src/models/tick.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Exponential Moving Average', () {
    List<Tick> ticks;

    setUpAll(() {
      ticks = const <Tick>[
        Tick(epoch: 1, quote: 64.75),
        Tick(epoch: 2, quote: 63.79),
        Tick(epoch: 3, quote: 63.73),
        Tick(epoch: 4, quote: 63.73),
        Tick(epoch: 5, quote: 63.55),
        Tick(epoch: 6, quote: 63.19),
        Tick(epoch: 7, quote: 63.91),
        Tick(epoch: 8, quote: 63.85),
        Tick(epoch: 9, quote: 62.95),
        Tick(epoch: 10, quote: 63.37),
        Tick(epoch: 11, quote: 61.33),
        Tick(epoch: 12, quote: 61.51),
      ];
    });

    test('EMAIndicator calculates the correct results', () {
      final EMAIndicator indicator =
          EMAIndicator(CloseValueIndicator(ticks), 10);

      expect(roundDouble(indicator.results[9].quote, 4), 63.6948);
      expect(roundDouble(indicator.results[10].quote, 4), 63.2649);
      expect(roundDouble(indicator.results[11].quote, 4), 62.9458);
    });
  });
}
