import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/line_series/zones_path_creator.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/conversion.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ZonesPathCreator', () {
    late List<Tick> ticks;
    late DataSeries<Tick> series;
    const double lineValue = 8.8;
    const Size canvasSize = Size(200, 300);
    late XAxisModel xAxisModel;
    late EpochToX epochToX;
    late QuoteToY quoteToY;
    late Offset Function(Tick) getTickPosition;

    setUpAll(() {
      ticks = const <Tick>[
        Tick(epoch: 0, quote: 10.1),
        Tick(epoch: 1000, quote: 10.2),
        Tick(epoch: 2000, quote: 10.9),
        Tick(epoch: 3000, quote: 9.5),
        Tick(epoch: 4000, quote: 8.7),
        Tick(epoch: 5000, quote: 8.1),
        Tick(epoch: 6000, quote: 8.9),
        Tick(epoch: 7000, quote: 9.1),
        Tick(epoch: 8000, quote: 9.2),
        Tick(epoch: 9000, quote: 9),
        Tick(epoch: 10000, quote: 8.5),
        Tick(epoch: 11000, quote: 8.4),
        Tick(epoch: 12000, quote: 8.7),
        Tick(epoch: 13000, quote: 9.1),
        Tick(epoch: 14000, quote: 9.5),
        Tick(epoch: 15000, quote: 9.2),
        Tick(epoch: 16000, quote: 9.3),
        Tick(epoch: 17000, quote: 9.6),
        Tick(epoch: 18000, quote: 10.1),
      ];

      series = LineSeries(ticks)..update(3000, 15000);

      xAxisModel = XAxisModel(
        entries: ticks,
        granularity: 1000,
        animationController: AnimationController(vsync: const TestVSync()),
        isLive: false,
      )..width = canvasSize.width;

      epochToX = (int epoch) => xAxisModel.xFromEpoch(epoch);
      quoteToY = (double quote) => quoteToCanvasY(
            quote: quote,
            topBoundQuote: 11,
            bottomBoundQuote: 6,
            canvasHeight: canvasSize.height,
            topPadding: 0,
            bottomPadding: 0,
          );

      getTickPosition =
          (Tick tick) => Offset(epochToX(tick.epoch), quoteToY(tick.quote));
    });

    test('TopZonesCreator', () {
      final TopZonePathCreator pathCreator = TopZonePathCreator(
        series: series,
        lineValue: lineValue,
        canvasSize: canvasSize,
      );

      expect(series.visibleEntries.first, ticks[2]);
      expect(pathCreator.isClosedInitially, false);

      for (int i = 3; i <= 4; i++) {
        pathCreator.addTick(
            ticks[i], i, getTickPosition(ticks[i]), epochToX, quoteToY);
      }

      expect(pathCreator.isClosed, true);
      expect(pathCreator.paths.length, 1);

      for (int i = 5; i <= 6; i++) {
        pathCreator.addTick(
            ticks[i], i, getTickPosition(ticks[i]), epochToX, quoteToY);
      }

      expect(pathCreator.isClosed, false);
      expect(pathCreator.paths.length, 1);

      for (int i = 7; i <= 10; i++) {
        pathCreator.addTick(
            ticks[i], i, getTickPosition(ticks[i]), epochToX, quoteToY);
      }

      expect(pathCreator.isClosed, true);
      expect(pathCreator.paths.length, 2);
    });

    test('BottomZonesCreator', () {
      final BottomZonePathCreator pathCreator = BottomZonePathCreator(
        series: series,
        lineValue: lineValue,
        canvasSize: canvasSize,
      );

      expect(series.visibleEntries.first, ticks[2]);
      expect(pathCreator.isClosedInitially, true);

      for (int i = 3; i <= 4; i++) {
        pathCreator.addTick(
            ticks[i], i, getTickPosition(ticks[i]), epochToX, quoteToY);
      }

      expect(pathCreator.isClosed, false);
      expect(pathCreator.paths.length, 0);

      for (int i = 5; i <= 6; i++) {
        pathCreator.addTick(
            ticks[i], i, getTickPosition(ticks[i]), epochToX, quoteToY);
      }

      expect(pathCreator.isClosed, true);
      expect(pathCreator.paths.length, 1);

      for (int i = 7; i <= 10; i++) {
        pathCreator.addTick(
            ticks[i], i, getTickPosition(ticks[i]), epochToX, quoteToY);
      }

      expect(pathCreator.isClosed, false);
      expect(pathCreator.paths.length, 1);

      for (int i = 11; i <= 13; i++) {
        pathCreator.addTick(
            ticks[i], i, getTickPosition(ticks[i]), epochToX, quoteToY);
      }

      expect(pathCreator.isClosed, true);
      expect(pathCreator.paths.length, 2);
    });
  });
}
