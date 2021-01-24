import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/lowest_value_indicator.dart';
import 'package:deriv_technical_analysis/src/models/data_input.dart';
import 'package:deriv_technical_analysis/src/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Lowest value indicator test', () {
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
        TickEntry(epoch: 10, quote: 61.37),
        TickEntry(epoch: 11, quote: 56.37),
        TickEntry(epoch: 12, quote: 48.51),
      ];
    });

    test('LowestValueIndicator calculates the correct results', () {
      final LowestValueIndicator indicator =
          LowestValueIndicator(CloseValueIndicator(Input(ticks)), 10);

      expect(indicator.results[9].quote, 61.37);
      expect(indicator.results[10].quote, 56.37);
      expect(indicator.results[11].quote, 48.51);
    });
  });
}
