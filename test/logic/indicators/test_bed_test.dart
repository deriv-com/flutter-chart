import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/abstract_ema_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/quote_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/parabolic_sar.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/sma_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/some_indicators.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/wma_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/zelma_indicator.dart';
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
      final List<Tick> ticks = <Tick>[
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

      EMAIndicator indicator = EMAIndicator(QuoteIndicator(ticks), 10);

      expect(indicator.getValue(9).quote, 63.694826748355545);
      expect(indicator.getValue(10).quote, 63.264858248654534);
      expect(indicator.getValue(11).quote, 62.945793112535526);
    });

    test('ZELMA', () {
      // , , , , , , , , , , ,
      final ticks = <Tick>[
        Tick(epoch: 1, quote: 10),
        Tick(epoch: 1, quote: 15),
        Tick(epoch: 1, quote: 20),
        Tick(epoch: 1, quote: 18),
        Tick(epoch: 1, quote: 17),
        Tick(epoch: 1, quote: 18),
        Tick(epoch: 1, quote: 15),
        Tick(epoch: 1, quote: 12),
        Tick(epoch: 1, quote: 10),
        Tick(epoch: 1, quote: 8),
        Tick(epoch: 1, quote: 5),
        Tick(epoch: 1, quote: 2),
      ];

      ZLEMAIndicator indicator = ZLEMAIndicator(QuoteIndicator(ticks), 10);

      final List<Tick> result = <Tick>[];

      for (int i = 0; i < ticks.length; i++) {
        result.add(indicator.getValue(i));
      }

      expect(result[9].quote, 11.909090909090908);
      expect(result[10].quote, 8.83471074380165);
      expect(result[11].quote, 5.773854244928623);
    });

    test('WAM', () {
      final List<Tick> ticks = <Tick>[
        Tick(epoch: 1, quote: 1.0),
        Tick(epoch: 1, quote: 2.0),
        Tick(epoch: 1, quote: 3.0),
        Tick(epoch: 1, quote: 4.0),
        Tick(epoch: 1, quote: 5.0),
        Tick(epoch: 1, quote: 6.0),
      ];
      WMAIndicator wmaIndicator = new WMAIndicator(QuoteIndicator(ticks), 3);

      expect(wmaIndicator.getValue(0).quote, 1);
      expect(wmaIndicator.getValue(1).quote, 1.6666666666666667);
      expect(wmaIndicator.getValue(2).quote, 2.3333333333333335);
      expect(wmaIndicator.getValue(3).quote, 3.3333333333333335);
      expect(wmaIndicator.getValue(4).quote, 4.333333333333333);
      expect(wmaIndicator.getValue(5).quote, 5.333333333333333);
    });
  });
}
