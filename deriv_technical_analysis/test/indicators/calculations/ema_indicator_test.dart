import 'package:deriv_technical_analysis/src/helpers/functions.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/ema_indicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_technical_analysis/src/models/data_input.dart';
import 'package:deriv_technical_analysis/src/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Exponential Moving Average', () {
    List<TickEntry> ticks;

    setUpAll(() {
      ticks = const <TickEntry>[
        TickEntry(epoch: 1, quote: 64.75),
        TickEntry(epoch: 2, quote: 63.79),
        TickEntry(epoch: 3, quote: 63.73),
        TickEntry(epoch: 4, quote: 63.73),
        TickEntry(epoch: 5, quote: 63.55),
        TickEntry(epoch: 6, quote: 63.19),
        TickEntry(epoch: 7, quote: 63.91),
        TickEntry(epoch: 8, quote: 63.85),
        TickEntry(epoch: 9, quote: 62.95),
        TickEntry(epoch: 10, quote: 63.37),
        TickEntry(epoch: 11, quote: 61.33),
        TickEntry(epoch: 12, quote: 61.51),
      ];
    });

    test('EMAIndicator calculates the correct results', () {
      final EMAIndicator indicator =
          EMAIndicator(CloseValueIndicator(Input(ticks)), 10);

      expect(roundDouble(indicator.results[9].quote, 4), 63.6948);
      expect(roundDouble(indicator.results[10].quote, 4), 63.2649);
      expect(roundDouble(indicator.results[11].quote, 4), 62.9458);
    });
  });
}
