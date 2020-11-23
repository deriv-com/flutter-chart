import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/abstract_ema_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/parabolic_sar.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/sma_indicator.dart';
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

    test('Parabolic SAR', () {
      ParabolicSarIndicator parabolicSarIndicator =
          ParabolicSarIndicator(candles);

      print('');
    });

    test('EMA', () {
      final List<Candle> candles = <Candle>[
        Candle(epoch: 1, high: 1, low: 1, open: 1, close: 64.75),
        Candle(epoch: 2, high: 1, low: 1, open: 1, close: 63.79),
        Candle(epoch: 3, high: 1, low: 1, open: 1, close: 63.73),
        Candle(epoch: 4, high: 1, low: 1, open: 1, close: 63.73),
        Candle(epoch: 5, high: 1, low: 1, open: 1, close: 63.55),
        Candle(epoch: 6, high: 1, low: 1, open: 1, close: 63.19),
        Candle(epoch: 7, high: 1, low: 1, open: 1, close: 63.91),
        Candle(epoch: 8, high: 1, low: 1, open: 1, close: 63.85),
        Candle(epoch: 9, high: 1, low: 1, open: 1, close: 62.95),
        Candle(epoch: 10, high: 1, low: 1, open: 1, close: 63.37),
        Candle(epoch: 11, high: 1, low: 1, open: 1, close: 61.33),
        Candle(epoch: 12, high: 1, low: 1, open: 1, close: 61.51),
      ];

      EMAIndicator indicator = EMAIndicator(CloseValueIndicator(candles), 10);

      expect(indicator.getValue(9).quote, 63.694826748355545);
      expect(indicator.getValue(10).quote, 63.264858248654534);
      expect(indicator.getValue(11).quote, 62.945793112535526);
    });
  });
}
