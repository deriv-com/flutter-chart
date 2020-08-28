import 'package:flutter_test/flutter_test.dart';

import 'package:deriv_chart/src/x_axis/grid/time_label.dart';

void main() {
  test('start of day -> date in format `2 Jul`', () {
    expect(
      timeLabel(DateTime.parse('2020-07-02 00:00:00Z')),
      '2 Jul',
    );
  });
  test('start of the month -> full month name', () {
    expect(
      timeLabel(DateTime.parse('2020-07-01 00:00:00Z')),
      'July',
    );
  });
  test('start of the year -> year', () {
    expect(
      timeLabel(DateTime.parse('2020-01-01 00:00:00Z')),
      '2020',
    );
  });
}
