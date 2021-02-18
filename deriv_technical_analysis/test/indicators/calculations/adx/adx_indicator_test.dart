import 'package:deriv_technical_analysis/src/helpers/functions.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/adx/adx_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mock_models.dart';

void main() {
  List<MockTick> ticks;

  setUpAll(() {
    ticks = const <MockTick>[
      MockOHLC(00, null, 44.52, 44.53, 43.98),
      MockOHLC(01, null, 44.65, 44.93, 44.36),
      MockOHLC(02, null, 45.22, 45.39, 44.70),
      MockOHLC(03, null, 45.45, 45.70, 45.13),
      MockOHLC(04, null, 45.49, 45.63, 44.89),
      MockOHLC(05, null, 44.24, 45.52, 44.20),
      MockOHLC(06, null, 44.62, 44.71, 44),
      MockOHLC(07, null, 45.15, 45.15, 43.76),
      MockOHLC(08, null, 44.54, 45.65, 44.46),
      MockOHLC(09, null, 45.66, 45.87, 45.13),
      MockOHLC(10, null, 45.95, 45.99, 45.27),
      MockOHLC(11, null, 46.33, 46.35, 45.80),
      MockOHLC(12, null, 46.31, 46.61, 46.10),
      MockOHLC(13, null, 45.94, 46.47, 45.77),
      MockOHLC(14, null, 45.60, 46.30, 45.14),
      MockOHLC(15, null, 45.70, 45.98, 44.97),
      MockOHLC(16, null, 46.56, 46.68, 46.10),
      MockOHLC(17, null, 46.36, 46.59, 46.14),
      MockOHLC(18, null, 46.83, 46.88, 46.39),
      MockOHLC(19, null, 46.72, 46.81, 46.41),
      MockOHLC(20, null, 46.65, 46.74, 45.94),
      MockOHLC(21, null, 46.97, 47.08, 46.68),
      MockOHLC(22, null, 46.56, 46.64, 46.17),
      MockOHLC(23, null, 45.29, 45.81, 45.10),
      MockOHLC(24, null, 44.94, 45.13, 44.35),
      MockOHLC(25, null, 44.62, 44.96, 44.61),
      MockOHLC(26, null, 44.70, 45.01, 44.20),
      MockOHLC(27, null, 45.27, 45.67, 44.93),
      MockOHLC(28, null, 45.44, 45.71, 45.01),
      MockOHLC(29, null, 44.76, 45.35, 44.46),
    ];
  });

  group('adx Indicator test.', () {
    test(
        'adx indicator should caluclatethe correct results from the given ticks',
        () {
      final ADXIndicator<MockResult> adxIndicator =
          ADXIndicator<MockResult>(MockInput(ticks))..calculateValues();

      expect(roundDouble(adxIndicator.getValue(27).quote, 2), 23.86);
      expect(roundDouble(adxIndicator.getValue(29).quote, 2), 23.86);
    });
  });
}
