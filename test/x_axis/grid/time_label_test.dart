import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deriv_chart/src/x_axis/grid/time_label.dart';
import 'package:deriv_chart/src/x_axis/x_axis_model.dart';

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
          epoch: 1607558400000,
          high: 0,
          low: 851.119,
          open: 851.572,
          close: 852.636),
      Candle(
          epoch: 1607644800000,
          high: 0,
          low: 851.119,
          open: 851.572,
          close: 852.636),
      Candle(
          epoch: 1607731200000,
          high: 0,
          low: 851.119,
          open: 851.572,
          close: 852.636),
      Candle(
          epoch: 1607990400000,
          high: 0,
          low: 851.119,
          open: 851.572,
          close: 852.636),
      Candle(
          epoch: 1608163200000,
          high: 0,
          low: 843.53,
          open: 851.608,
          close: 844.591),
    ];

    final XAxisModel mockModel = XAxisModel(
      entries: entries,
      granularity: 8640000,
      animationController: AnimationController.unbounded(vsync: TestVSync()),
      isLive: false,
    );

    mockModel.width = 200;

    final List<DateTime> noOverLapTimeStamps = [
      DateTime.utc(2020, 12, 10, 0, 0, 0, 0),
      DateTime.utc(2020, 12, 11, 0, 0, 0, 0),
      DateTime.utc(2020, 12, 12, 0, 0, 0, 0),
      DateTime.utc(2020, 12, 15, 0, 0, 0, 0),
      DateTime.utc(2020, 12, 17, 0, 0, 0, 0)
    ];
    expect(
      mockModel.getNoOverlapGridTimestamps(),
      noOverLapTimeStamps,
    );
  });
}
