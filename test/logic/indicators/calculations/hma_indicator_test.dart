import 'package:deriv_chart/src/helpers/helper_functions.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_chart/src/logic/indicators/calculations/hma_indicator.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Hull Moving Average', () {
    List<Tick> ticks;

    setUpAll(() {
      ticks = const <Tick>[
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
    });

    test('HMAIndicator calculates the correct result', () {
      final HMAIndicator hma = HMAIndicator(CloseValueIndicator(ticks), 9);

      expect(roundDouble(hma.results[10].quote, 4), 86.3204);
      expect(roundDouble(hma.results[11].quote, 4), 85.3705);
      expect(roundDouble(hma.results[12].quote, 4), 84.1044);
      expect(roundDouble(hma.results[13].quote, 4), 83.0197);
      expect(roundDouble(hma.results[14].quote, 4), 81.3913);
      expect(roundDouble(hma.results[15].quote, 4), 79.6511);
      expect(roundDouble(hma.results[16].quote, 4), 78.0443);
      expect(roundDouble(hma.results[17].quote, 4), 76.8832);
      expect(roundDouble(hma.results[18].quote, 4), 75.5363);
      expect(roundDouble(hma.results[19].quote, 4), 75.1713);
      expect(roundDouble(hma.results[20].quote, 4), 75.3597);
    });
  });
}
