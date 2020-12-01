import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/bollinger/bollinger_bands_middle_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/bollinger/bollinger_bands_upper_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/bollinger/percent_b_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/parabolic_sar.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/sma_indicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/Ichimoku_indicators.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/statistics/standard_deviation_indicator.dart';
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
    });

    test('Parabolic SAR', () {
      ParabolicSarIndicator parabolicSarIndicator =
          ParabolicSarIndicator(candles);
    });

    test('Bollinger middle', () {
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

      SMAIndicator sma = SMAIndicator(CloseValueIndicator(ticks), 3);
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

      final closePrice = new CloseValueIndicator(ticks);

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

      final closePrice = CloseValueIndicator(ticks);

      PercentBIndicator pcb = new PercentBIndicator(closePrice, 5);

      expect(pcb.results[0].quote.isNaN, isTrue);
      expect(roundDouble(pcb.results[1].quote, 2), 0.75);
      expect(roundDouble(pcb.results[2].quote, 4), 0.8244);
      expect(roundDouble(pcb.results[3].quote, 4), 0.6627);
      expect(roundDouble(pcb.results[4].quote, 4), 0.8517);
      expect(roundDouble(pcb.results[5].quote, 5), 0.90328);
      expect(roundDouble(pcb.results[6].quote, 2), 0.83);
      expect(roundDouble(pcb.results[7].quote, 4), 0.6552);
      expect(roundDouble(pcb.results[8].quote, 4), 0.5737);
      expect(roundDouble(pcb.results[9].quote, 4), 0.1047);
      expect(pcb.results[10].quote, 0.5);
      expect(roundDouble(pcb.results[11].quote, 4), 0.0284);
      expect(roundDouble(pcb.results[12].quote, 4), 0.0344);
      expect(roundDouble(pcb.results[13].quote, 4), 0.2064);
      expect(roundDouble(pcb.results[14].quote, 4), 0.1835);
      expect(roundDouble(pcb.results[15].quote, 4), 0.2131);
      expect(roundDouble(pcb.results[16].quote, 4), 0.3506);
      expect(roundDouble(pcb.results[17].quote, 4), 0.5737);
      expect(pcb.results[18].quote, 0.5);
      expect(roundDouble(pcb.results[19].quote, 4), 0.7673);
    });
  });
}
