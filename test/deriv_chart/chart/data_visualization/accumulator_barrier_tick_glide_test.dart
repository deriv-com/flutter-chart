import 'dart:ui' as ui;

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/barriers/accumulators_barriers/accumulator_barrier_geometry.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/barriers/accumulators_barriers/accumulators_indicator_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// How the band moves between ticks, with and without a growth rate previewed.
///
/// The preview owns the band's width. Its position is the spot's, which keeps
/// moving while the picker is open — so a previewed band has to glide exactly
/// as an un-previewed one does.
const List<AccumulatorGrowthRateStep> _ladder = <AccumulatorGrowthRateStep>[
  AccumulatorGrowthRateStep(growthRate: 0.01, barrierSpotDistance: 4),
  AccumulatorGrowthRateStep(growthRate: 0.03, barrierSpotDistance: 1),
];

/// Quote 100 renders at y=0 and every unit of quote is a pixel, so a band's
/// pixel geometry can be read as prices.
double _quoteToY(double quote) => 100 - quote;

double _epochToX(int epoch) => epoch.toDouble();

AccumulatorIndicator _bandAt(
  double quote, {
  double distance = 1,
  AccumulatorBarrierDragController? controller,
}) =>
    AccumulatorIndicator(
      Tick(epoch: 1000, quote: quote),
      lowBarrier: quote - distance,
      highBarrier: quote + distance,
      lowBarrierDisplay: '${quote - distance}',
      highBarrierDisplay: '${quote + distance}',
      barrierSpotDistance: '$distance',
      barrierEpoch: 1000,
      dragController: controller,
    );

/// Paints one frame and reports the band it actually rendered.
({double center, double height}) _render(
  AccumulatorIndicator band,
  AccumulatorBarrierDragController controller,
  double tickPercent,
) {
  AccumulatorIndicatorPainter(band).paint(
    canvas: Canvas(ui.PictureRecorder()),
    size: const Size(400, 200),
    epochToX: _epochToX,
    quoteToY: _quoteToY,
    animationInfo: AnimationInfo(currentTickPercent: tickPercent),
    chartConfig: const ChartConfig(pipSize: 2, granularity: 1000),
    theme: ChartDefaultDarkTheme(),
    chartScaleModel: const ChartScaleModel(granularity: 1000, msPerPx: 1000),
  );

  // The painter publishes the geometry it just resolved, so this is the band
  // on screen rather than a second guess at it.
  final AccumulatorBarrierGeometry geometry = controller.geometry!;
  return (
    center: (geometry.highBarrierY + geometry.lowBarrierY) / 2,
    height: (geometry.lowBarrierY - geometry.highBarrierY).abs(),
  );
}

/// Moves the band on to the next tick, the way a rebuild does.
AccumulatorIndicator _advance(
  AccumulatorIndicator from,
  AccumulatorIndicator to,
) {
  to.didUpdate(from);
  return to;
}

void main() {
  late AccumulatorBarrierDragController controller;

  setUp(() {
    controller = AccumulatorBarrierDragController(steps: _ladder);
  });

  tearDown(() => controller.dispose());

  /// The band stepping from quote 100 to quote 120.
  AccumulatorIndicator movedBand() => _advance(
        _bandAt(100, controller: controller),
        _bandAt(120, controller: controller),
      );

  test('glides between ticks when nothing is previewed', () {
    final AccumulatorIndicator band = movedBand();

    expect(_render(band, controller, 0).center, closeTo(0, 0.01));
    expect(_render(band, controller, 0.5).center, closeTo(-10, 0.01));
    expect(_render(band, controller, 1).center, closeTo(-20, 0.01));
  });

  test('glides between ticks while a rate is previewed, too', () {
    final AccumulatorIndicator band = movedBand();
    controller.previewGrowthRate(0.01);

    // The regression: the band used to be drawn around the incoming tick's
    // centre outright, so it arrived at the new price on the first frame while
    // the X axis was still easing across — a vertical jump, and nothing else.
    expect(_render(band, controller, 0).center, closeTo(0, 0.01));
    expect(_render(band, controller, 0.5).center, closeTo(-10, 0.01));
    expect(_render(band, controller, 1).center, closeTo(-20, 0.01));
  });

  test('keeps the previewed width the whole way across', () {
    final AccumulatorIndicator band = movedBand();
    controller.previewGrowthRate(0.01);

    // The rung is 4 away from the centre either side, against the model's 1.
    for (final double percent in <double>[0, 0.5, 1]) {
      expect(_render(band, controller, percent).height, closeTo(8, 0.01));
    }
  });

  test('still animates the width when the model itself moves the barriers', () {
    // No preview, and the band widens as it moves: both axes of the change
    // ease together.
    final AccumulatorIndicator band = _advance(
      _bandAt(100, controller: controller),
      _bandAt(100, distance: 3, controller: controller),
    );

    expect(_render(band, controller, 0).height, closeTo(2, 0.01));
    expect(_render(band, controller, 1).height, closeTo(6, 0.01));
  });
}
