import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/x_axis/grid/calc_time_grid.dart';
import 'package:deriv_chart/src/x_axis/x_axis_helper.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deriv_chart/src/x_axis/grid/time_label.dart';
import 'package:deriv_chart/src/x_axis/x_axis.dart';
import 'package:deriv_chart/src/x_axis/x_axis_model.dart';
import 'package:intl/intl.dart';

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

  test('test should Remove labels inside time gaps and have overlap', () {
    final List<Tick> entries = [
      Candle(
          epoch: 1607584691000,
          high: 0,
          low: 851.119,
          open: 851.572,
          close: 852.636),
      Candle(
          epoch: 1608275891000,
          high: 0,
          low: 843.53,
          open: 851.608,
          close: 844.591),
      Candle(
          epoch: 1608362291000,
          high: 0,
          low: 844.48,
          open: 844.59,
          close: 846.896),
      Candle(
          epoch: 1608448691000,
          high: 0,
          low: 836.228,
          open: 846.91,
          close: 846.811),
      Candle(
          epoch: 1608535091000,
          high: 0,
          low: 845.391,
          open: 846.808,
          close: 852.305),
      Candle(
          epoch: 1608794291000,
          high: 0,
          low: 849.084,
          open: 852.29,
          close: 850.09),
      Candle(
          epoch: 1608880691000,
          high: 0,
          low: 843.535,
          open: 848.56,
          close: 845.139),
      Candle(
          epoch: 1609053491000,
          high: 0,
          low: 844.759,
          open: 845.145,
          close: 852.769),
      Candle(
          epoch: 1609139891000,
          high: 0,
          low: 845.272,
          open: 852.772,
          close: 848.126),
      Candle(
          epoch: 1609226291000,
          high: 0,
          low: 848.05,
          open: 848.137,
          close: 850.821),
    ];

    final XAxisModel mockModel = XAxisModel(
      entries: entries,
      granularity: 8640000,
      animationController: AnimationController.unbounded(vsync: TestVSync()),
      isLive: false,
    );

    mockModel.width = 1000;

    final List<DateTime> noOverLapTimeStamps = [];
    expect(
      getNoOverlapGridTimestamps(mockModel),
      noOverLapTimeStamps,
    );
  });
}
