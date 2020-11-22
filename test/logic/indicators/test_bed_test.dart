import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/indicator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Indicators', () {
    List<Candle> candles;

    setUpAll(() {
      candles = <Candle>[
        Candle(epoch: 10, high: 12, low: 8, open: 8, close: 10),
        Candle(epoch: 11, high: 14, low: 10, open: 11, close: 11.5),
        Candle(epoch: 12, high: 10, low: 8, open: 9, close: 9.5),
        Candle(epoch: 13, high: 16, low: 12, open: 15.5, close: 12.5),
        Candle(epoch: 14, high: 11, low: 9, open: 9, close: 10.5)
      ];
    });

    test('Ichimoku test', () {
      AbstractIchimokuLineIndicator abstractIchimokuLineIndicator =
          AbstractIchimokuLineIndicator(candles, 3);

      print('object');
    });

    test('SMAIndicator', () {
      SMAIndicator smaIndicator = SMAIndicator(HighValueIndicator(candles), 2);

      print('object');
    });
  });
}
