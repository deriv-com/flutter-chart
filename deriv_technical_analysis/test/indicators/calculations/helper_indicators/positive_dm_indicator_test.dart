import 'package:deriv_technical_analysis/src/helpers/functions.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/helper_indicators/positive_dm_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mock_models.dart';

void main() {
  List<MockTick> ticks;

  setUpAll(() {
    ticks = const <MockTick>[
      MockOHLC.withNames(
          epoch: 01, high: 80.859, low: 80.850, open: 80.858, close: 80.857),
      MockOHLC.withNames(
          epoch: 02, high: 80.860, low: 80.850, open: 80.858, close: 80.855),
      MockOHLC.withNames(
          epoch: 03, high: 80.861, low: 80.846, open: 80.855, close: 80.858),
      MockOHLC.withNames(
          epoch: 04, high: 80.868, low: 80.855, open: 80.860, close: 80.863),
      MockOHLC.withNames(
          epoch: 05, high: 80.886, low: 80.863, open: 80.864, close: 80.877),
      MockOHLC.withNames(
          epoch: 06, high: 80.886, low: 80.877, open: 80.879, close: 80.886),
      MockOHLC.withNames(
          epoch: 07, high: 80.896, low: 80.883, open: 80.883, close: 80.892),
      MockOHLC.withNames(
          epoch: 08, high: 80.899, low: 80.889, open: 80.891, close: 80.899),
      MockOHLC.withNames(
          epoch: 09, high: 80.899, low: 80.888, open: 80.898, close: 80.890),
      MockOHLC.withNames(
          epoch: 10, high: 80.893, low: 80.888, open: 80.891, close: 80.893),
      MockOHLC.withNames(
          epoch: 11, high: 80.899, low: 80.892, open: 80.892, close: 80.898),
      MockOHLC.withNames(
          epoch: 12, high: 80.902, low: 80.895, open: 80.898, close: 80.895),
      MockOHLC.withNames(
          epoch: 13, high: 80.902, low: 80.894, open: 80.894, close: 80.901),
      MockOHLC.withNames(
          epoch: 14, high: 80.903, low: 80.894, open: 80.901, close: 80.896),
      MockOHLC.withNames(
          epoch: 15, high: 80.898, low: 80.892, open: 80.897, close: 80.895),
      MockOHLC.withNames(
          epoch: 16, high: 80.898, low: 80.891, open: 80.897, close: 80.892),
      MockOHLC.withNames(
          epoch: 17, high: 80.898, low: 08.887, open: 80.892, close: 80.897),
      MockOHLC.withNames(
          epoch: 18, high: 80.922, low: 80.893, open: 80.895, close: 80.921),
    ];
  });

  group('Positive DM Indicator.', () {
    test(
        'Positive DM Inicator should calculate the correct result from the given candles.',
        () {
      final PositiveDMIndicator<MockResult> positiveDMIndicator =
          PositiveDMIndicator<MockResult>(MockInput(ticks));

      expect(positiveDMIndicator.getValue(0).quote, 0);
      expect(roundDouble(positiveDMIndicator.getValue(1).quote, 3), 0.001);
      expect(positiveDMIndicator.getValue(2).quote, 0);
      expect(roundDouble(positiveDMIndicator.getValue(3).quote, 3), 0.007);
    });
  });
}
