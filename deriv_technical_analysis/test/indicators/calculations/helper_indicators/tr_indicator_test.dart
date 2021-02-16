import 'package:deriv_technical_analysis/src/helpers/functions.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/tr_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mock_models.dart';

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
    ];
  });

  group('TR Indicator test', () {
    test(
        'TR Indicator should calculate the currect result from the given ticks.',
        () {
      final TRIndicator<MockResult> trIndicator =
          TRIndicator<MockResult>(MockInput(ticks));

      expect(roundDouble(trIndicator.getValue(0).quote, 3), 0.011);
      expect(roundDouble(trIndicator.getValue(1).quote, 3), 0.014);
      expect(roundDouble(trIndicator.getValue(2).quote, 3), 0.014);
      expect(roundDouble(trIndicator.getValue(3).quote, 3), 0.012);
      expect(roundDouble(trIndicator.getValue(4).quote, 3), 0.014);
      expect(roundDouble(trIndicator.getValue(5).quote, 3), 0.021);
    });
  });
}
