import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/sma_indicator.dart';
import 'package:deriv_technical_analysis/src/models/data_input.dart';
import 'package:deriv_technical_analysis/src/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Simple Moving Average', () {
    List<TickEntry> ticks;

    setUpAll(() {
      ticks = const <TickEntry>[
        TickEntry(epoch: 10, quote: 1),
        TickEntry(epoch: 11, quote: 2),
        TickEntry(epoch: 12, quote: 3),
        TickEntry(epoch: 13, quote: 4),
        TickEntry(epoch: 14, quote: 3),
        TickEntry(epoch: 15, quote: 4),
        TickEntry(epoch: 16, quote: 5),
        TickEntry(epoch: 17, quote: 4),
        TickEntry(epoch: 18, quote: 3),
        TickEntry(epoch: 19, quote: 3),
        TickEntry(epoch: 20, quote: 4),
        TickEntry(epoch: 21, quote: 3),
        TickEntry(epoch: 22, quote: 2),
      ];
    });

    test('SMAIndicator calculates the correct results', () {
      final SMAIndicator smaIndicator =
          SMAIndicator(CloseValueIndicator(Input(ticks)), 3);

      expect(1, smaIndicator.getValue(0).quote);
      expect(1.5, smaIndicator.getValue(1).quote);
      expect(2, smaIndicator.getValue(2).quote);
      expect(3, smaIndicator.getValue(3).quote);
      expect(10 / 3, smaIndicator.getValue(4).quote);
      expect(11 / 3, smaIndicator.getValue(5).quote);
      expect(4, smaIndicator.getValue(6).quote);
      expect(13 / 3, smaIndicator.getValue(7).quote);
      expect(4, smaIndicator.getValue(8).quote);
      expect(10 / 3, smaIndicator.getValue(9).quote);
      expect(10 / 3, smaIndicator.getValue(10).quote);
      expect(10 / 3, smaIndicator.getValue(11).quote);
      expect(3, smaIndicator.getValue(12).quote);
    });
  });
}
