import 'package:deriv_technical_analysis/src/helpers/functions.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/close_value_inidicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/statistics/standard_deviation_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mock_models.dart';

void main() {
  group('StandardDeviationIndicator', () {
    List<MockOHLC> ticks;

    setUpAll(() {
      ticks = const <MockOHLC>[
        MockOHLC.withNames(
            epoch: 1, open: 64.75, close: 64.12, high: 67.5, low: 63),
        MockOHLC.withNames(
            epoch: 2, open: 73.5, close: 74.62, high: 75.65, low: 73.12),
        MockOHLC.withNames(
            epoch: 3, open: 74.2, close: 73.42, high: 76.3, low: 73.33),
        MockOHLC.withNames(
            epoch: 4, open: 70.12, close: 72.2, high: 73.5, low: 70.12),
        MockOHLC.withNames(
            epoch: 5, open: 73.21, close: 73.64, high: 76.3, low: 72.31),
      ];
    });

    test(
        'StandardDeviationIndicator calculates the correct results from CloseValueIndicator.',
        () {
      final StandardDeviationIndicator<MockResult> indicator =
          StandardDeviationIndicator<MockResult>(
              CloseValueIndicator<MockResult>(MockInput(ticks)), 5);

      expect(roundDouble(indicator.getValue(1).quote, 4), 5.25);
      expect(roundDouble(indicator.getValue(2).quote, 4), 4.6925);
      expect(roundDouble(indicator.getValue(3).quote, 4), 4.1141);
      expect(roundDouble(indicator.getValue(4).quote, 4), 3.8185);
    });
  });
}
