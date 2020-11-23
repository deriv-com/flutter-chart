import 'dart:math';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/abstract_ema_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/bollinger/bollinger_bands_middle_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/bollinger/bollinger_bands_upper_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/bollinger/percent_b_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/quote_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/hma_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/parabolic_sar.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/sma_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/some_indicators.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/statistics/standard_deviation_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/wma_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/zelma_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

double roundDouble(double value, int places) =>
    double.tryParse(value.toStringAsFixed(places));

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

    test('HMA Indicator', () {
      final List<Tick> ticks = <Tick>[
        Tick(epoch: 1, quote: 84.53),
        Tick(epoch: 2, quote: 87.39),
        Tick(epoch: 3, quote: 84.55),
        Tick(epoch: 4, quote: 82.83),
        Tick(epoch: 5, quote: 82.58),
        Tick(epoch: 6, quote: 83.74),
        Tick(epoch: 7, quote: 83.33),
        Tick(epoch: 8, quote: 84.57),
        Tick(epoch: 9, quote: 86.98),
        Tick(epoch: 10, quote: 87.10),
        Tick(epoch: 11, quote: 83.11),
        Tick(epoch: 12, quote: 83.60),
        Tick(epoch: 13, quote: 83.66),
        Tick(epoch: 14, quote: 82.76),
        Tick(epoch: 15, quote: 79.22),
        Tick(epoch: 16, quote: 79.03),
        Tick(epoch: 17, quote: 78.18),
        Tick(epoch: 18, quote: 77.42),
        Tick(epoch: 19, quote: 74.65),
        Tick(epoch: 20, quote: 77.48),
        Tick(epoch: 21, quote: 76.87),
      ];

      final HMAIndicator hma = HMAIndicator(QuoteIndicator(ticks), 9);

      expect(hma.getValue(10).quote, 86.32044444444443);
      expect(hma.getValue(11).quote, 85.37048148148149);
      expect(hma.getValue(12).quote, 84.10444444444447);
      expect(hma.getValue(13).quote, 83.01974074074077);
      expect(hma.getValue(14).quote, 81.39133333333335);
      expect(hma.getValue(15).quote, 79.6511111111111);
      expect(hma.getValue(16).quote, 78.04429629629628);
      expect(hma.getValue(17).quote, 76.88322222222223);
      expect(hma.getValue(18).quote, 75.53633333333335);
      expect(hma.getValue(19).quote, 75.17129629629629);
      expect(hma.getValue(20).quote, 75.35974074074075);
    });

    test('Bollinger middle', () {
      // 1, 2, 3, 4, 3, 4, 5, 4, 3, 3, 4, 3, 2
      final List<Tick> ticks = <Tick>[
        Tick(epoch: 1, quote: 1),
        Tick(epoch: 2, quote: 2),
        Tick(epoch: 3, quote: 3),
        Tick(epoch: 4, quote: 4),
        Tick(epoch: 5, quote: 3),
        Tick(epoch: 6, quote: 4),
        Tick(epoch: 7, quote: 5),
        Tick(epoch: 8, quote: 4),
        Tick(epoch: 9, quote: 3),
        Tick(epoch: 10, quote: 3),
        Tick(epoch: 11, quote: 4),
        Tick(epoch: 12, quote: 3),
        Tick(epoch: 13, quote: 2),
      ];

      SMAIndicator sma = SMAIndicator(QuoteIndicator(ticks), 3);
      BollingerBandsMiddleIndicator bbmSMA = BollingerBandsMiddleIndicator(sma);

      for (int i = 0; i < ticks.length; i++) {
        expect(bbmSMA.getValue(i).quote, sma.getValue(i).quote);
      }
    });

    test('Bollinger uper', () {
      final List<Tick> ticks = <Tick>[
        Tick(epoch: 1, quote: 1),
        Tick(epoch: 2, quote: 2),
        Tick(epoch: 3, quote: 3),
        Tick(epoch: 4, quote: 4),
        Tick(epoch: 5, quote: 3),
        Tick(epoch: 6, quote: 4),
        Tick(epoch: 7, quote: 5),
        Tick(epoch: 8, quote: 4),
        Tick(epoch: 9, quote: 3),
        Tick(epoch: 10, quote: 3),
        Tick(epoch: 11, quote: 4),
        Tick(epoch: 12, quote: 3),
        Tick(epoch: 13, quote: 2),
      ];

      final barCount = 3;

      final closePrice = new QuoteIndicator(ticks);

      BollingerBandsMiddleIndicator bbmSMA =
          new BollingerBandsMiddleIndicator(SMAIndicator(closePrice, barCount));
      StandardDeviationIndicator standardDeviation =
          new StandardDeviationIndicator(closePrice, barCount);
      BollingerBandsUpperIndicator bbuSMA =
          new BollingerBandsUpperIndicator(bbmSMA, standardDeviation);

      expect(bbuSMA.k, 2);

      expect(bbuSMA.getValue(0).quote, 1);
      expect(bbuSMA.getValue(1).quote, 2.5);
      expect(roundDouble(bbuSMA.getValue(2).quote, 3), 3.633);
      expect(roundDouble(bbuSMA.getValue(3).quote, 3), 4.633);
      expect(roundDouble(bbuSMA.getValue(4).quote, 4), 4.2761);
      expect(roundDouble(bbuSMA.getValue(5).quote, 4), 4.6095);
      expect(roundDouble(bbuSMA.getValue(6).quote, 3), 5.633);
      expect(roundDouble(bbuSMA.getValue(7).quote, 4), 5.2761);
      expect(roundDouble(bbuSMA.getValue(8).quote, 3), 5.633);
      expect(roundDouble(bbuSMA.getValue(9).quote, 4), 4.2761);

      BollingerBandsUpperIndicator bbuSMAwithK =
          new BollingerBandsUpperIndicator(bbmSMA, standardDeviation, k: 1.5);

      expect(bbuSMAwithK.k, 1.5);

      expect(bbuSMAwithK.getValue(0).quote, 1);
      expect(bbuSMAwithK.getValue(1).quote, 2.25);
      expect(roundDouble(bbuSMAwithK.getValue(2).quote, 4), 3.2247);
      expect(roundDouble(bbuSMAwithK.getValue(3).quote, 4), 4.2247);
      expect(roundDouble(bbuSMAwithK.getValue(4).quote, 4), 4.0404);
      expect(roundDouble(bbuSMAwithK.getValue(5).quote, 4), 4.3738);
      expect(roundDouble(bbuSMAwithK.getValue(6).quote, 4), 5.2247);
      expect(roundDouble(bbuSMAwithK.getValue(7).quote, 4), 5.0404);
      expect(roundDouble(bbuSMAwithK.getValue(8).quote, 4), 5.2247);
      expect(roundDouble(bbuSMAwithK.getValue(9).quote, 4), 4.0404);
    });

    test('Bollinger Percent B', () {
      final List<Tick> ticks = <Tick>[
        Tick(epoch: 1, quote: 10),
        Tick(epoch: 2, quote: 12),
        Tick(epoch: 3, quote: 15),
        Tick(epoch: 4, quote: 14),
        Tick(epoch: 5, quote: 17),
        Tick(epoch: 6, quote: 20),
        Tick(epoch: 7, quote: 21),
        Tick(epoch: 8, quote: 20),
        Tick(epoch: 9, quote: 20),
        Tick(epoch: 10, quote: 19),
        Tick(epoch: 11, quote: 20),
        Tick(epoch: 12, quote: 17),
        Tick(epoch: 13, quote: 12),
        Tick(epoch: 14, quote: 12),
        Tick(epoch: 15, quote: 9),
        Tick(epoch: 16, quote: 8),
        Tick(epoch: 17, quote: 9),
        Tick(epoch: 18, quote: 10),
        Tick(epoch: 19, quote: 9),
        Tick(epoch: 20, quote: 10),
      ];

      final closePrice = QuoteIndicator(ticks);

      PercentBIndicator pcb = new PercentBIndicator(closePrice, 5, 2);

      expect(pcb.getValue(0).quote.isNaN, isTrue);
      expect(roundDouble(pcb.getValue(1).quote, 2), 0.75);
      expect(roundDouble(pcb.getValue(2).quote, 4), 0.8244);
      expect(roundDouble(pcb.getValue(3).quote, 4), 0.6627);
      expect(roundDouble(pcb.getValue(4).quote, 4), 0.8517);
      expect(roundDouble(pcb.getValue(5).quote, 5), 0.90328);
      expect(roundDouble(pcb.getValue(6).quote, 2), 0.83);
      expect(roundDouble(pcb.getValue(7).quote, 4), 0.6552);
      expect(roundDouble(pcb.getValue(8).quote, 4), 0.5737);
      expect(roundDouble(pcb.getValue(9).quote, 4), 0.1047);
      expect(pcb.getValue(10).quote, 0.5);
      expect(roundDouble(pcb.getValue(11).quote, 4), 0.0284);
      expect(roundDouble(pcb.getValue(12).quote, 4), 0.0344);
      expect(roundDouble(pcb.getValue(13).quote, 4), 0.2064);
      expect(roundDouble(pcb.getValue(14).quote, 4), 0.1835);
      expect(roundDouble(pcb.getValue(15).quote, 4), 0.2131);
      expect(roundDouble(pcb.getValue(16).quote, 4), 0.3506);
      expect(roundDouble(pcb.getValue(17).quote, 4), 0.5737);
      expect(pcb.getValue(18).quote, 0.5);
      expect(roundDouble(pcb.getValue(19).quote, 4), 0.7673);
    });
  });
}
