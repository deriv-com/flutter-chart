import 'package:deriv_technical_analysis/src/helpers/functions.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/stochastic/slow_stochastic_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mock_models.dart';

void main() {
  List<MockTick> ticks;

  setUpAll(() {
    ticks = const <MockTick>[
      MockOHLC(01, null, 127.01, 127.01, 125.36),
      MockOHLC(02, null, 127.62, 127.62, 126.16),
      MockOHLC(03, null, 126.59, 126.59, 124.93),
      MockOHLC(04, null, 127.35, 127.35, 126.09),
      MockOHLC(05, null, 128.17, 128.17, 126.82),
      MockOHLC(06, null, 128.43, 128.43, 126.48),
      MockOHLC(07, null, 127.37, 127.37, 126.03),
      MockOHLC(08, null, 126.42, 126.42, 124.83),
      MockOHLC(09, null, 126.90, 126.90, 126.39),
      MockOHLC(10, null, 126.85, 126.85, 125.72),
      MockOHLC(11, null, 125.65, 125.65, 124.56),
      MockOHLC(12, null, 125.72, 125.72, 124.57),
      MockOHLC(13, null, 127.16, 127.16, 125.07),
      MockOHLC(14, null, 127.29, 127.72, 126.86),
      MockOHLC(15, null, 127.18, 127.69, 126.63),
      MockOHLC(16, null, 128.01, 128.22, 126.80),
      MockOHLC(17, null, 127.11, 128.27, 126.71),
      MockOHLC(18, null, 127.73, 128.09, 126.80),
      MockOHLC(19, null, 127.06, 128.27, 126.13),
      MockOHLC(20, null, 127.33, 127.74, 125.92),
      MockOHLC(21, null, 128.71, 128.77, 126.99),
      MockOHLC(22, null, 127.87, 129.29, 127.81),
      MockOHLC(23, null, 128.58, 130.06, 128.47),
      MockOHLC(24, null, 128.60, 129.12, 128.06),
      MockOHLC(25, null, 127.93, 129.29, 127.61),
      MockOHLC(26, null, 128.11, 128.47, 127.60),
      MockOHLC(27, null, 127.60, 128.09, 127),
      MockOHLC(28, null, 127.60, 128.65, 126.90),
      MockOHLC(29, null, 128.69, 129.14, 127.49),
    ];
  });

  group('Slow Stochastic Indicator test.', () {
    test(
        'Slow Stochastic Indicator should caclulate the correct results from the given ticks.',
        () {
      final SlowStochasticIndicator<MockResult> slowStochasticIndicator =
          SlowStochasticIndicator<MockResult>(
        MockInput(ticks),
      );

      expect(roundDouble(slowStochasticIndicator.getValue(24).quote, 2), 69.25);
      expect(roundDouble(slowStochasticIndicator.getValue(25).quote, 2), 65.19);
      expect(roundDouble(slowStochasticIndicator.getValue(26).quote, 2), 54.23);
      expect(roundDouble(slowStochasticIndicator.getValue(27).quote, 2), 47.36);
      expect(roundDouble(slowStochasticIndicator.getValue(28).quote, 2), 49.36);
    });
  });
}
