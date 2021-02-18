import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/mma_indicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/smma_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock_models.dart';

void main() {
  List<MockTick> ticks;

  setUpAll(() {
    ticks = const <MockTick>[
      MockOHLC(0, 79.523, 79.526, 79.536, 79.522),
      MockOHLC(1, 79.525, 79.529, 79.534, 79.522),
      MockOHLC(2, 79.528, 79.532, 79.532, 79.518),
      MockOHLC(3, 79.533, 79.525, 79.539, 79.518),
      MockOHLC(4, 79.525, 79.514, 79.528, 79.505),
      MockOHLC(5, 79.515, 79.510, 79.516, 79.507),
      MockOHLC(6, 79.509, 79.507, 79.512, 79.503),
      MockOHLC(7, 79.507, 79.518, 79.520, 79.504),
      MockOHLC(8, 79.517, 79.507, 79.523, 79.507),
    ];
  });

  group('Smoothed Moving Average Indicator.', () {
    test(
        'Smoothed Moving Average Indicator should calculate correct results from the given closed value indicator ticks.',
        () {
      final CloseValueIndicator<MockResult> closeValueIndicator =
          CloseValueIndicator<MockResult>(MockInput(ticks));

      final SMMAIndicator<MockResult> smmaIndicator =
          SMMAIndicator<MockResult>(closeValueIndicator, 2, 2);

      expect(smmaIndicator.getValue(0).quote, 79.526);
      expect(smmaIndicator.getValue(1).quote, 79.529);
      expect(smmaIndicator.getValue(2).quote, 79.532);
      expect(smmaIndicator.getValue(3).quote, 79.525);
    });
  });
}
