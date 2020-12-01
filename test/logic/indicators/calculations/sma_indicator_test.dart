import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/sma_indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Simple Moving Average', () {
    List<Tick> ticks;

    setUpAll(() {
      ticks = <Tick>[
        Tick(epoch: 10, quote: 1),
        Tick(epoch: 11, quote: 2),
        Tick(epoch: 12, quote: 3),
        Tick(epoch: 13, quote: 4),
        Tick(epoch: 14, quote: 3),
        Tick(epoch: 15, quote: 4),
        Tick(epoch: 16, quote: 5),
        Tick(epoch: 17, quote: 4),
        Tick(epoch: 18, quote: 3),
        Tick(epoch: 19, quote: 3),
        Tick(epoch: 20, quote: 4),
        Tick(epoch: 21, quote: 3),
        Tick(epoch: 22, quote: 2),
      ];
    });

    test('SMAIndicator', () {
      SMAIndicator smaIndicator = SMAIndicator(CloseValueIndicator(ticks), 3);

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
