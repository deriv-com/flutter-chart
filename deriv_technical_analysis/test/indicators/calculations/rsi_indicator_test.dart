import 'package:deriv_technical_analysis/src/helpers/functions.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/rsi_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock_models.dart';

void main() {
  List<MockTick> ticks;

  setUpAll(() {
    ticks = const <MockTick>[
      MockOHLC(00, 79.537, 79.532, 79.540, 79.529),
      MockOHLC(01, 79.532, 79.524, 79.536, 79.522),
      MockOHLC(02, 79.523, 79.526, 79.536, 79.522),
      MockOHLC(03, 79.525, 79.529, 79.534, 79.522),
      MockOHLC(04, 79.528, 79.532, 79.532, 79.518),
      MockOHLC(05, 79.533, 79.525, 79.539, 79.518),
      MockOHLC(06, 79.525, 79.514, 79.528, 79.505),
      MockOHLC(07, 79.515, 79.510, 79.516, 79.507),
      MockOHLC(08, 79.509, 79.507, 79.512, 79.503),
      MockOHLC(09, 79.507, 79.518, 79.520, 79.504),
      MockOHLC(10, 79.517, 79.507, 79.523, 79.507),
      MockOHLC(11, 79.510, 79.509, 79.515, 79.505),
      MockOHLC(12, 79.508, 79.513, 79.518, 79.508),
      MockOHLC(13, 79.513, 79.526, 79.526, 79.513),
      MockOHLC(14, 79.526, 79.526, 79.527, 79.521),
      MockOHLC(15, 79.526, 79.544, 79.547, 79.525),
      MockOHLC(16, 79.546, 79.545, 79.547, 79.533),
      MockOHLC(17, 79.545, 79.556, 79.559, 79.538),
      MockOHLC(18, 79.557, 79.554, 79.562, 79.544),
      MockOHLC(19, 79.555, 79.549, 79.559, 79.548),
      MockOHLC(20, 79.550, 79.548, 79.554, 79.545),
    ];
  });

  group('Relative Strength Index Indicator test.', () {
    test(
        'Relative Strength Index should calculate the correct results from the given closed value indicator ticks.',
        () {
      final CloseValueIndicator<MockResult> closeValueIndicator =
          CloseValueIndicator<MockResult>(MockInput(ticks));
      final RSIIndicator<MockResult> rsiIndicator =
          RSIIndicator<MockResult>.fromIndicator(closeValueIndicator, 14);

      expect(rsiIndicator.getValue(0).quote, 0);
      expect(roundDouble(rsiIndicator.getValue(14).quote, 2), 52.88);
      expect(roundDouble(rsiIndicator.getValue(15).quote, 2), 65.42);
      expect(roundDouble(rsiIndicator.getValue(16).quote, 2), 65.96);
      expect(roundDouble(rsiIndicator.getValue(17).quote, 2), 71.28);
    });
  });
}
