import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/barriers/accumulators_barriers/accumulator_barrier_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A five-rung ladder, widest band first, like the growth-rate range a host
/// supplies (a higher growth rate means a tighter band).
const List<AccumulatorGrowthRateStep> _ladder = <AccumulatorGrowthRateStep>[
  AccumulatorGrowthRateStep(growthRate: 0.01, barrierSpotDistance: 5),
  AccumulatorGrowthRateStep(growthRate: 0.02, barrierSpotDistance: 4),
  AccumulatorGrowthRateStep(growthRate: 0.03, barrierSpotDistance: 3),
  AccumulatorGrowthRateStep(growthRate: 0.04, barrierSpotDistance: 2),
  AccumulatorGrowthRateStep(growthRate: 0.05, barrierSpotDistance: 1),
];

AccumulatorIndicator _buildIndicator({
  AccumulatorBarrierDragController? dragController,
  AccumulatorsActiveContract? activeContract,
}) =>
    AccumulatorIndicator(
      const Tick(epoch: 1000, quote: 100),
      lowBarrier: 97,
      highBarrier: 103,
      highBarrierDisplay: '103',
      lowBarrierDisplay: '97',
      barrierSpotDistance: '3',
      barrierEpoch: 1000,
      activeContract: activeContract,
      dragController: dragController,
    );

void main() {
  group('AccumulatorBarrierDragController.nearestStep', () {
    late AccumulatorBarrierDragController controller;

    setUp(() {
      controller = AccumulatorBarrierDragController(steps: _ladder);
    });

    tearDown(() => controller.dispose());

    test('returns null when the ladder is empty', () {
      final AccumulatorBarrierDragController empty =
          AccumulatorBarrierDragController();
      expect(empty.nearestStep(3), isNull);
      empty.dispose();
    });

    test('snaps to the closest step by barrier distance', () {
      expect(controller.nearestStep(0.9)?.growthRate, 0.05);
      expect(controller.nearestStep(2.4)?.growthRate, 0.04);
      expect(controller.nearestStep(100)?.growthRate, 0.01);
    });

    test('hysteresis keeps the current preview across a boundary', () {
      controller
        ..beginDrag(AccumulatorBarrierSide.high)
        ..updateDrag(_ladder[2]); // distance 3

      // 2.4 is nearer to step 2.0, but only by 0.2 — inside the 0.5 slack.
      expect(controller.nearestStep(2.4, hysteresis: 0.5)?.growthRate, 0.03);

      // Far enough past the boundary, the preview gives way.
      expect(controller.nearestStep(2.0, hysteresis: 0.5)?.growthRate, 0.04);
    });

    test('hysteresis is ignored when no preview is active', () {
      expect(controller.nearestStep(2.4, hysteresis: 0.5)?.growthRate, 0.04);
    });
  });

  group('AccumulatorBarrierDragController drag lifecycle', () {
    test('reports start, each snap, and the settled step', () {
      final List<double> updates = <double>[];
      double? settled;
      int starts = 0;

      final AccumulatorBarrierDragController controller =
          AccumulatorBarrierDragController(
        steps: _ladder,
        onDragStart: () => starts++,
        onDragUpdate: (AccumulatorGrowthRateStep step) =>
            updates.add(step.growthRate),
        onDragEnd: (AccumulatorGrowthRateStep step) =>
            settled = step.growthRate,
      )
            ..beginDrag(AccumulatorBarrierSide.low)
            ..updateDrag(_ladder[1])
            // Repeating the same step must not re-notify.
            ..updateDrag(_ladder[1])
            ..updateDrag(_ladder[0])
            ..endDrag(commit: true);

      expect(starts, 1);
      expect(updates, <double>[0.02, 0.01]);
      expect(settled, 0.01);
      expect(controller.isDragging, isFalse);
      // The preview is latched until the model moves or the timeout fires.
      expect(controller.previewStep, _ladder[0]);

      controller.dispose();
    });

    test('a cancelled drag drops the preview and does not commit', () {
      bool committed = false;
      final AccumulatorBarrierDragController controller =
          AccumulatorBarrierDragController(
        steps: _ladder,
        onDragEnd: (AccumulatorGrowthRateStep _) => committed = true,
      )
            ..beginDrag(AccumulatorBarrierSide.high)
            ..updateDrag(_ladder[4])
            ..endDrag(commit: false);

      expect(committed, isFalse);
      expect(controller.previewStep, isNull);

      controller.dispose();
    });

    test('disabling clears any in-flight interaction', () {
      final AccumulatorBarrierDragController controller =
          AccumulatorBarrierDragController(steps: _ladder)
            ..beginDrag(AccumulatorBarrierSide.high)
            ..updateDrag(_ladder[0])
            ..enabled = false;

      expect(controller.isDragging, isFalse);
      expect(controller.previewStep, isNull);
      expect(controller.hoveredSide, isNull);

      controller.dispose();
    });
  });

  group('AccumulatorBarrierDragController commit latch', () {
    late AccumulatorBarrierDragController controller;

    setUp(() {
      controller = AccumulatorBarrierDragController(steps: _ladder)
        ..publishGeometry(_geometry(committedSpotDistance: 3))
        ..beginDrag(AccumulatorBarrierSide.high)
        ..updateDrag(_ladder[0])
        ..endDrag(commit: true);
    });

    tearDown(() => controller.dispose());

    test('holds the preview while the model has not moved', () {
      expect(
        controller.releaseLatchIfModelMoved(highBarrier: 103, lowBarrier: 97),
        isFalse,
      );
      expect(controller.previewStep, _ladder[0]);
    });

    test('releases as soon as the model moves', () {
      expect(
        controller.releaseLatchIfModelMoved(highBarrier: 105, lowBarrier: 95),
        isTrue,
      );
      expect(controller.previewStep, isNull);
    });

    test('releases only once', () {
      controller.releaseLatchIfModelMoved(highBarrier: 105, lowBarrier: 95);
      expect(
        controller.releaseLatchIfModelMoved(highBarrier: 110, lowBarrier: 90),
        isFalse,
      );
    });

    test('clearPreview drops the latch', () {
      controller.clearPreview();
      expect(controller.previewStep, isNull);
      expect(
        controller.releaseLatchIfModelMoved(highBarrier: 105, lowBarrier: 95),
        isFalse,
      );
    });
  });

  group('AccumulatorBarrierGeometry.hitTest', () {
    final AccumulatorBarrierGeometry geometry = _geometry();

    test('hits a grip', () {
      expect(
        geometry.hitTest(
          const Offset(150, 100),
          lineTolerance: 2,
          minTouchTarget: Size.zero,
        ),
        AccumulatorBarrierSide.high,
      );
      expect(
        geometry.hitTest(
          const Offset(150, 200),
          lineTolerance: 2,
          minTouchTarget: Size.zero,
        ),
        AccumulatorBarrierSide.low,
      );
    });

    test('hits a barrier line away from the grip', () {
      expect(
        geometry.hitTest(
          const Offset(260, 101),
          lineTolerance: 4,
          minTouchTarget: Size.zero,
        ),
        AccumulatorBarrierSide.high,
      );
    });

    test('misses outside the band and between the barriers', () {
      expect(
        geometry.hitTest(
          const Offset(260, 150),
          lineTolerance: 4,
          minTouchTarget: Size.zero,
        ),
        isNull,
      );
      expect(
        geometry.hitTest(
          const Offset(20, 100),
          lineTolerance: 4,
          minTouchTarget: Size.zero,
        ),
        isNull,
      );
    });

    test('inflates small grips to the minimum touch target', () {
      const Offset justBelowTheGrip = Offset(150, 115);

      expect(
        geometry.hitTest(
          justBelowTheGrip,
          lineTolerance: 2,
          minTouchTarget: Size.zero,
        ),
        isNull,
      );
      expect(
        geometry.hitTest(
          justBelowTheGrip,
          lineTolerance: 2,
          minTouchTarget: const Size(44, 44),
        ),
        AccumulatorBarrierSide.high,
      );
    });
  });

  group('AccumulatorIndicator', () {
    test('has no preview without a controller', () {
      expect(_buildIndicator().previewStep, isNull);
    });

    test('ignores the controller once a contract is active', () {
      final AccumulatorBarrierDragController controller =
          AccumulatorBarrierDragController(steps: _ladder)
            ..beginDrag(AccumulatorBarrierSide.high)
            ..updateDrag(_ladder[0]);

      expect(
        _buildIndicator(
          dragController: controller,
          activeContract: const AccumulatorsActiveContract(
            profit: 1,
            profitUnit: 'USD',
            fractionalDigits: 2,
          ),
        ).previewStep,
        isNull,
      );

      controller.dispose();
    });

    test('recalculateMinMax follows the committed band when idle', () {
      final AccumulatorIndicator indicator = _buildIndicator()
        ..onUpdate(0, 2000);

      // Band 97..103 plus half of its own delta (3) on each side.
      expect(indicator.recalculateMinMax(), <double>[94, 106]);
    });

    test('recalculateMinMax follows the preview while dragging', () {
      final AccumulatorBarrierDragController controller =
          AccumulatorBarrierDragController(steps: _ladder)
            ..beginDrag(AccumulatorBarrierSide.high)
            // Distance 5 around the committed centre of 100 -> 95..105.
            ..updateDrag(_ladder[0]);

      final AccumulatorIndicator indicator =
          _buildIndicator(dragController: controller)..onUpdate(0, 2000);

      expect(indicator.recalculateMinMax(), <double>[90, 110]);

      controller.dispose();
    });

    test('recalculateMinMax reports NaN when out of range', () {
      final AccumulatorIndicator indicator = _buildIndicator()
        ..onUpdate(5000, 6000);

      expect(indicator.recalculateMinMax().every((double v) => v.isNaN), true);
    });
  });
}

AccumulatorBarrierGeometry _geometry({double committedSpotDistance = 3}) =>
    AccumulatorBarrierGeometry(
      barrierX: 100,
      rightEdgeX: 300,
      highBarrierY: 100,
      lowBarrierY: 200,
      highGripRect: const Rect.fromLTWH(135, 94, 31, 12),
      lowGripRect: const Rect.fromLTWH(135, 194, 31, 12),
      bandCenterQuote: 100,
      committedBarrierSpotDistance: committedSpotDistance,
    );
