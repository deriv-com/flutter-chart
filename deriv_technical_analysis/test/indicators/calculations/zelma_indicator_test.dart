import 'package:deriv_technical_analysis/src/helpers/functions.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/zelma_indicator.dart';
import 'package:deriv_technical_analysis/src/models/data_input.dart';
import 'package:deriv_technical_analysis/src/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Zero-lag Exponential Moving Average', () {
    List<TickEntry> ticks;

    setUpAll(() {
      ticks = const <TickEntry>[
        TickEntry(epoch: 1, quote: 10),
        TickEntry(epoch: 1, quote: 15),
        TickEntry(epoch: 1, quote: 20),
        TickEntry(epoch: 1, quote: 18),
        TickEntry(epoch: 1, quote: 17),
        TickEntry(epoch: 1, quote: 18),
        TickEntry(epoch: 1, quote: 15),
        TickEntry(epoch: 1, quote: 12),
        TickEntry(epoch: 1, quote: 10),
        TickEntry(epoch: 1, quote: 8),
        TickEntry(epoch: 1, quote: 5),
        TickEntry(epoch: 1, quote: 2),
      ];
    });

    test('ZLEMAIndicator calculates the correct results', () {
      final ZLEMAIndicator indicator =
          ZLEMAIndicator(CloseValueIndicator(Input(ticks)), 10);

      expect(roundDouble(indicator.results[9].quote, 3), 11.909);
      expect(roundDouble(indicator.results[10].quote, 4), 8.8347);
      expect(roundDouble(indicator.results[11].quote, 4), 5.7739);
    });
  });
}
