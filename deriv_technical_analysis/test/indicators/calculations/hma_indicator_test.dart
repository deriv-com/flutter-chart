import 'package:deriv_technical_analysis/src/helpers/functions.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/hma_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock_models.dart';

void main() {
  group('Hull Moving Average', () {
    List<MockTick> ticks;

    setUpAll(() {
      ticks = const <MockTick>[
        MockTick(epoch: 1, quote: 84.53),
        MockTick(epoch: 2, quote: 87.39),
        MockTick(epoch: 3, quote: 84.55),
        MockTick(epoch: 4, quote: 82.83),
        MockTick(epoch: 5, quote: 82.58),
        MockTick(epoch: 6, quote: 83.74),
        MockTick(epoch: 7, quote: 83.33),
        MockTick(epoch: 8, quote: 84.57),
        MockTick(epoch: 9, quote: 86.98),
        MockTick(epoch: 10, quote: 87.10),
        MockTick(epoch: 11, quote: 83.11),
        MockTick(epoch: 12, quote: 83.60),
        MockTick(epoch: 13, quote: 83.66),
        MockTick(epoch: 14, quote: 82.76),
        MockTick(epoch: 15, quote: 79.22),
        MockTick(epoch: 16, quote: 79.03),
        MockTick(epoch: 17, quote: 78.18),
        MockTick(epoch: 18, quote: 77.42),
        MockTick(epoch: 19, quote: 74.65),
        MockTick(epoch: 20, quote: 77.48),
        MockTick(epoch: 21, quote: 76.87),
      ];
    });

    test('HMAIndicator calculates the correct result', () {
      final HMAIndicator<MockResult> hma = HMAIndicator<MockResult>(
        CloseValueIndicator<MockResult>(MockInput(ticks)),
        9,
      );

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
