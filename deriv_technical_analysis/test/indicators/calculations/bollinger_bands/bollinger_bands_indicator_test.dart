import 'package:deriv_technical_analysis/src/helpers/functions.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/bollinger/bollinger_bands_upper_indicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/bollinger/percent_b_indicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/sma_indicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/statistics/standard_deviation_indicator.dart';
import 'package:deriv_technical_analysis/src/indicators/indicator.dart';
import 'package:deriv_technical_analysis/src/models/data_input.dart';
import 'package:deriv_technical_analysis/src/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BollingerBands Indicator', () {
    test('BollingerBandsUpperIndicator calculates the correct result', () {
      const List<TickEntry> ticks = <TickEntry>[
        TickEntry(epoch: 1, quote: 1),
        TickEntry(epoch: 2, quote: 2),
        TickEntry(epoch: 3, quote: 3),
        TickEntry(epoch: 4, quote: 4),
        TickEntry(epoch: 5, quote: 3),
        TickEntry(epoch: 6, quote: 4),
        TickEntry(epoch: 7, quote: 5),
        TickEntry(epoch: 8, quote: 4),
        TickEntry(epoch: 9, quote: 3),
        TickEntry(epoch: 10, quote: 3),
        TickEntry(epoch: 11, quote: 4),
        TickEntry(epoch: 12, quote: 3),
        TickEntry(epoch: 13, quote: 2),
      ];

      const int period = 3;

      final CloseValueIndicator closePrice = CloseValueIndicator(Input(ticks));

      final Indicator bbmSMA = SMAIndicator(closePrice, period);
      final StandardDeviationIndicator standardDeviation =
          StandardDeviationIndicator(closePrice, period);
      final BollingerBandsUpperIndicator bbuSMA =
          BollingerBandsUpperIndicator(bbmSMA, standardDeviation);

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

      final BollingerBandsUpperIndicator bbuSMAwithK =
          BollingerBandsUpperIndicator(bbmSMA, standardDeviation, k: 1.5);

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

    test('Bollinger Percent B calculates the correct result', () {
      const List<TickEntry> ticks = <TickEntry>[
        TickEntry(epoch: 1, quote: 10),
        TickEntry(epoch: 2, quote: 12),
        TickEntry(epoch: 3, quote: 15),
        TickEntry(epoch: 4, quote: 14),
        TickEntry(epoch: 5, quote: 17),
        TickEntry(epoch: 6, quote: 20),
        TickEntry(epoch: 7, quote: 21),
        TickEntry(epoch: 8, quote: 20),
        TickEntry(epoch: 9, quote: 20),
        TickEntry(epoch: 10, quote: 19),
        TickEntry(epoch: 11, quote: 20),
        TickEntry(epoch: 12, quote: 17),
        TickEntry(epoch: 13, quote: 12),
        TickEntry(epoch: 14, quote: 12),
        TickEntry(epoch: 15, quote: 9),
        TickEntry(epoch: 16, quote: 8),
        TickEntry(epoch: 17, quote: 9),
        TickEntry(epoch: 18, quote: 10),
        TickEntry(epoch: 19, quote: 9),
        TickEntry(epoch: 20, quote: 10),
      ];

      final Indicator closePrice = CloseValueIndicator(Input(ticks));

      final PercentBIndicator pcb = PercentBIndicator(closePrice, 5);

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
