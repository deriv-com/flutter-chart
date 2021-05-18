import 'package:deriv_chart/src/components/x_axis/min_candle_duration_for_data_fit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('minCandleDurationForDataFit works', () {
    expect(
      minCandleDurationForDataFit(
        const Duration(seconds: 30),
        236,
      ),
      const Duration(seconds: 6),
    );
  });
}
