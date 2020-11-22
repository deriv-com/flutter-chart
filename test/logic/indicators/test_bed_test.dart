import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/some_indicators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Indicators', () {
    List<Candle> candles;

    setUpAll(() {
      candles = <Candle>[
        Candle(epoch: 10, high: 4, low: 0.2, open: 3, close: 1),
        Candle(epoch: 11, high: 2, low: 0.7, open: 1, close: 2),
        Candle(epoch: 12, high: 5, low: 2, open: 4, close: 3),
        Candle(epoch: 13, high: 6, low: 3, open: 3, close: 4),
        Candle(epoch: 14, high: 5, low: 2, open: 4, close: 3),
        Candle(epoch: 15, high: 7, low: 3, open: 6, close: 4),
        Candle(epoch: 16, high: 8, low: 2, open: 4, close: 5),
        Candle(epoch: 17, high: 6.2, low: 1, open: 5, close: 4),
        Candle(epoch: 18, high: 3, low: 0, open: 1, close: 3),
        Candle(epoch: 19, high: 5, low: 2.2, open: 2.8, close: 3),
        Candle(epoch: 20, high: 6.2, low: 1, open: 5.4, close: 4),
        Candle(epoch: 21, high: 4, low: 1, open: 2, close: 3),
        Candle(epoch: 22, high: 6, low: 1, open: 1, close: 2),
      ];
    });

    test('Ichimoku test', () {
      AbstractIchimokuLineIndicator abstractIchimokuLineIndicator =
          AbstractIchimokuLineIndicator(candles, 3);

      print('object');
    });

    test('SMAIndicator', () {
      SMAIndicator smaIndicator = SMAIndicator(CloseValueIndicator(candles), 3);

      expect(1, smaIndicator.getValue(0));
      expect(1.5, smaIndicator.getValue(1));
      expect(2, smaIndicator.getValue(2));
      expect(3, smaIndicator.getValue(3));
      expect(10 / 3, smaIndicator.getValue(4));
      expect(11 / 3, smaIndicator.getValue(5));
      expect(4, smaIndicator.getValue(6));
      expect(13 / 3, smaIndicator.getValue(7));
      expect(4, smaIndicator.getValue(8));
      expect(10 / 3, smaIndicator.getValue(9));
      expect(10 / 3, smaIndicator.getValue(10));
      expect(10 / 3, smaIndicator.getValue(11));
      expect(3, smaIndicator.getValue(12));
    });
  });
}
