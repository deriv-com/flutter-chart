import 'package:flutter_test/flutter_test.dart';

import '../mock_models.dart';

void main() {
  List<MockTick> ticks;

  setUpAll(() {
    ticks = const <MockTick>[
      MockOHLC(00, 79.537, 79.532, 79.540, 79.520),
      MockOHLC(01, 79.532, 79.524, 79.530, 79.520),
      MockOHLC(02, 79.523, 79.526, 79.530, 79.520),
      MockOHLC(03, 79.525, 79.529, 79.530, 79.520),
      MockOHLC(04, 79.528, 79.532, 79.530, 79.510),
      MockOHLC(05, 79.533, 79.525, 79.530, 79.510),
      MockOHLC(06, 79.525, 79.514, 79.520, 79.500),
      MockOHLC(07, 79.515, 79.510, 79.510, 79.500),
      MockOHLC(08, 79.509, 79.507, 79.510, 79.500),
      MockOHLC(09, 79.507, 79.518, 79.520, 79.500),
    ];
  });

  group('ATR Indicator test', () {
    test(
        'ATR Indicator should calculate the correct result from the given ticks and period.',
        () {});
  });
}
