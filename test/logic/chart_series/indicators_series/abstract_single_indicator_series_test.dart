import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/abstract_single_indicator_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/indicator_options.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:deriv_technical_analysis/src/indicators/cached_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

class MockOptions extends IndicatorOptions {
  @override
  List<Object> get props => <Object>[];
}

class MockMASeries extends AbstractSingleIndicatorSeries {
  MockMASeries(
    IndicatorInput input, {
    int offset,
  }) : super(
          CloseValueIndicator<Tick>(input),
          'MOCK_MA_SERIES',
          MockOptions(),
          offset: offset,
        );

  @override
  SeriesPainter<Series> createPainter() => LinePainter(this);

  @override
  CachedIndicator<Tick> initializeIndicator() =>
      SMAIndicator<Tick>(inputIndicator, 2);
}

void main() {
  group('Abstract Single indicator series getEpochOf', () {
    group('''getEpochOf returns correct result 
        when there is offset and NO market gaps''', () {
      IndicatorInput input;
      setUp(() {
        input = IndicatorInput(
          const <Tick>[
            Tick(epoch: 1000, quote: 1),
            Tick(epoch: 2000, quote: 3),
            Tick(epoch: 3000, quote: 2),
            Tick(epoch: 4000, quote: 0),
            Tick(epoch: 5000, quote: 4),
          ],
          1000,
        );
      });

      test('A portion of entries are visible and offset is +1', () {
        final MockMASeries maSeries = MockMASeries(input, offset: 1)
          ..update(2000, 4000);

        final List<Tick> visibleEntries = maSeries.visibleEntries.entries;
        final List<Tick> entries = input.entries;

        // Visible entries are in indices [1, 2, 3].
        expect(maSeries.getEpochOf(visibleEntries[0], 1), entries[2].epoch);
        expect(maSeries.getEpochOf(visibleEntries[1], 2), entries[3].epoch);
        expect(maSeries.getEpochOf(visibleEntries[2], 3), entries[4].epoch);
      });

      test('A portion of entries are visible and offset is -1', () {
        final MockMASeries maSeries = MockMASeries(input, offset: -1)
          ..update(2000, 4000);

        final List<Tick> visibleEntries = maSeries.visibleEntries.entries;
        final List<Tick> entries = input.entries;

        // Visible entries are in indices [1, 2, 3].
        expect(maSeries.getEpochOf(visibleEntries[0], 1), entries[0].epoch);
        expect(maSeries.getEpochOf(visibleEntries[1], 2), entries[1].epoch);
        expect(maSeries.getEpochOf(visibleEntries[2], 3), entries[2].epoch);
      });

      test('All entries are visible and offset is +1', () {
        final MockMASeries maSeries = MockMASeries(input, offset: 1)
          ..update(1000, 5000);

        final List<Tick> visibleEntries = maSeries.visibleEntries.entries;
        final List<Tick> entries = input.entries;

        // All entries are visible.
        expect(maSeries.getEpochOf(visibleEntries[0], 0), entries[1].epoch);
        expect(maSeries.getEpochOf(visibleEntries[1], 1), entries[2].epoch);
        expect(maSeries.getEpochOf(visibleEntries[2], 2), entries[3].epoch);
        expect(maSeries.getEpochOf(visibleEntries[3], 3), entries[4].epoch);
        expect(maSeries.getEpochOf(visibleEntries[4], 4), 6000);
      });

      test('All entries are visible and offset is +1', () {
        final MockMASeries maSeries = MockMASeries(input, offset: -1)
          ..update(1000, 5000);

        final List<Tick> visibleEntries = maSeries.visibleEntries.entries;
        final List<Tick> entries = input.entries;

        // All entries are visible.
        expect(maSeries.getEpochOf(visibleEntries[0], 0), 0);
        expect(maSeries.getEpochOf(visibleEntries[1], 1), entries[0].epoch);
        expect(maSeries.getEpochOf(visibleEntries[2], 2), entries[1].epoch);
        expect(maSeries.getEpochOf(visibleEntries[3], 3), entries[2].epoch);
        expect(maSeries.getEpochOf(visibleEntries[4], 4), entries[3].epoch);
      });
    });

    group('''getEpochOf returns correct result 
        when there is offset and there is market gaps''', () {
      IndicatorInput input;
      setUp(() {
        input = IndicatorInput(
          const <Tick>[
            Tick(epoch: 1000, quote: 1),
            Tick(epoch: 2000, quote: 3),
            Tick(epoch: 5000, quote: 2),
            Tick(epoch: 6000, quote: 0),
            Tick(epoch: 9000, quote: 4),
            Tick(epoch: 10000, quote: 3),
          ],
          1000,
        );
      });

      test('A portion of entries are visible and offset is +1', () {
        final MockMASeries maSeries = MockMASeries(input, offset: 1)
          ..update(2000, 9000);

        final List<Tick> visibleEntries = maSeries.visibleEntries.entries;
        final List<Tick> entries = input.entries;

        // Visible entries are in indices [1, 2, 3, 4].
        expect(maSeries.getEpochOf(visibleEntries[0], 1), entries[2].epoch);
        expect(maSeries.getEpochOf(visibleEntries[1], 2), entries[3].epoch);
        expect(maSeries.getEpochOf(visibleEntries[2], 3), entries[4].epoch);
        expect(maSeries.getEpochOf(visibleEntries[3], 4), entries[5].epoch);
      });

      test('A portion of entries are visible and offset is -1', () {
        final MockMASeries maSeries = MockMASeries(input, offset: -1)
          ..update(2000, 9000);

        final List<Tick> visibleEntries = maSeries.visibleEntries.entries;
        final List<Tick> entries = input.entries;

        // Visible entries are in indices [1, 2, 3, 4].
        expect(maSeries.getEpochOf(visibleEntries[0], 1), entries[0].epoch);
        expect(maSeries.getEpochOf(visibleEntries[1], 2), entries[1].epoch);
        expect(maSeries.getEpochOf(visibleEntries[2], 3), entries[2].epoch);
        expect(maSeries.getEpochOf(visibleEntries[3], 4), entries[3].epoch);
      });

      test('All entries are visible and offset is +1', () {
        final MockMASeries maSeries = MockMASeries(input, offset: 1)
          ..update(1000, 10000);

        final List<Tick> visibleEntries = maSeries.visibleEntries.entries;
        final List<Tick> entries = input.entries;

        // All entries are visible.
        expect(maSeries.getEpochOf(visibleEntries[0], 0), entries[1].epoch);
        expect(maSeries.getEpochOf(visibleEntries[1], 1), entries[2].epoch);
        expect(maSeries.getEpochOf(visibleEntries[2], 2), entries[3].epoch);
        expect(maSeries.getEpochOf(visibleEntries[3], 3), entries[4].epoch);
        expect(maSeries.getEpochOf(visibleEntries[4], 4), entries[5].epoch);
        expect(maSeries.getEpochOf(visibleEntries[5], 5), 11000);
      });

      test('All entries are visible and offset is +1', () {
        final MockMASeries maSeries = MockMASeries(input, offset: -1)
          ..update(1000, 10000);

        final List<Tick> visibleEntries = maSeries.visibleEntries.entries;
        final List<Tick> entries = input.entries;

        // All entries are visible.
        expect(maSeries.getEpochOf(visibleEntries[0], 0), 0);
        expect(maSeries.getEpochOf(visibleEntries[1], 1), entries[0].epoch);
        expect(maSeries.getEpochOf(visibleEntries[2], 2), entries[1].epoch);
        expect(maSeries.getEpochOf(visibleEntries[3], 3), entries[2].epoch);
        expect(maSeries.getEpochOf(visibleEntries[4], 4), entries[3].epoch);
        expect(maSeries.getEpochOf(visibleEntries[5], 5), entries[4].epoch);
      });
    });
  });
}
