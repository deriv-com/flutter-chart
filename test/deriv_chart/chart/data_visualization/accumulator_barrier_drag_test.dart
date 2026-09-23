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
  _placementTests();
  _ladderTests();
  _transitionTests();

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
          const Offset(260, 100),
          lineTolerance: 2,
          minTouchTarget: Size.zero,
        ),
        AccumulatorBarrierSide.high,
      );
      expect(
        geometry.hitTest(
          const Offset(260, 200),
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
      const Offset justBelowTheGrip = Offset(260, 118);

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
      highGripRect: const Rect.fromLTWH(232, 91, 56, 18),
      lowGripRect: const Rect.fromLTWH(232, 191, 56, 18),
      bandCenterQuote: 100,
      committedBarrierSpotDistance: committedSpotDistance,
    );

/// A realistic ladder: the accumulators barrier offsets the API returns are
/// nearly flat across growth rates, so the rungs sit ~6% apart rather than the
/// 2x-per-rate spread a naive model would assume.
const List<AccumulatorGrowthRateStep> _tightLadder =
    <AccumulatorGrowthRateStep>[
  AccumulatorGrowthRateStep(growthRate: 0.01, barrierSpotDistance: 0.6256),
  AccumulatorGrowthRateStep(growthRate: 0.03, barrierSpotDistance: 0.5484),
  AccumulatorGrowthRateStep(growthRate: 0.05, barrierSpotDistance: 0.4966),
];

void _placementTests() {
  group('AccumulatorBarrierGeometry.gripCenterX', () {
    const AccumulatorBarrierGripStyle style = AccumulatorBarrierGripStyle();

    test('pins the grip against the right of the plotting area', () {
      // 56 wide, 12 from the edge: centre sits 40 in from 400.
      expect(
        AccumulatorBarrierGeometry.gripCenterX(
          barrierX: 100,
          rightEdgeX: 400,
          style: style,
        ),
        360,
      );
    });

    test('ignores where the band starts while there is room', () {
      expect(
        AccumulatorBarrierGeometry.gripCenterX(
          barrierX: 200,
          rightEdgeX: 400,
          style: style,
        ),
        AccumulatorBarrierGeometry.gripCenterX(
          barrierX: 10,
          rightEdgeX: 400,
          style: style,
        ),
      );
    });

    test('keeps the grip inside a band too narrow to hold it', () {
      // Band starts at 360, so right-aligning would push the grip out its left
      // edge; it is held at the band's start instead.
      expect(
        AccumulatorBarrierGeometry.gripCenterX(
          barrierX: 360,
          rightEdgeX: 400,
          style: style,
        ),
        388,
      );
    });

    test('follows the plotting area, not the full canvas', () {
      // The Y-axis label strip is excluded, so a narrower plotting area moves
      // the grip left with it.
      expect(
        AccumulatorBarrierGeometry.gripCenterX(
          barrierX: 100,
          rightEdgeX: 300,
          style: style,
        ),
        260,
      );
    });
  });
}

void _transitionTests() {
  group('AccumulatorBarrierDragController preview transition', () {
    late AccumulatorBarrierDragController controller;

    setUp(() {
      controller = AccumulatorBarrierDragController(steps: _ladder)
        ..publishGeometry(_geometry(committedSpotDistance: 3))
        ..beginDrag(AccumulatorBarrierSide.high);
    });

    tearDown(() => controller.dispose());

    test('nothing to glide from before the first rung change', () {
      expect(controller.previewTransitionFrom, isNull);
    });

    test('the first rung change glides from the committed band', () {
      controller.updateDrag(_ladder[1]);

      expect(controller.previewTransitionFrom, 3);
    });

    test('a settled rung change glides from the previous rung', () {
      controller
        ..updateDrag(_ladder[1])
        // Painter reports the glide finished on the rung it was heading to.
        ..publishRenderedPreviewDistance(_ladder[1].barrierSpotDistance)
        ..updateDrag(_ladder[0]);

      expect(controller.previewTransitionFrom, _ladder[1].barrierSpotDistance);
    });

    test('a rung change mid-glide carries on from where the band is', () {
      controller
        ..updateDrag(_ladder[1])
        // Halfway between the committed 3 and the 4 it was heading to.
        ..publishRenderedPreviewDistance(3.5)
        ..updateDrag(_ladder[0]);

      // Not the rung it was leaving, and not the one it was heading to.
      expect(controller.previewTransitionFrom, 3.5);
    });

    test('exposes what was drawn so the commit can glide on from it', () {
      controller
        ..updateDrag(_ladder[0])
        ..publishRenderedPreviewDistance(4.8);

      expect(controller.renderedPreviewDistance, 4.8);
    });

    test('clearing the preview forgets the transition', () {
      controller
        ..updateDrag(_ladder[0])
        ..publishRenderedPreviewDistance(4.8)
        ..clearPreview();

      expect(controller.previewTransitionFrom, isNull);
      expect(controller.renderedPreviewDistance, isNull);
    });
  });
}

void _ladderTests() {
  group('AccumulatorBarrierDragController.ladderSpan', () {
    test('spans the tightest to the widest rung', () {
      final AccumulatorBarrierDragController controller =
          AccumulatorBarrierDragController(steps: _tightLadder);

      expect(controller.ladderSpan, closeTo(0.6256 - 0.4966, 1e-9));

      controller.dispose();
    });

    test('is zero when there is nothing to span', () {
      final AccumulatorBarrierDragController empty =
          AccumulatorBarrierDragController();
      final AccumulatorBarrierDragController single =
          AccumulatorBarrierDragController(steps: <AccumulatorGrowthRateStep>[
        _tightLadder.first,
      ]);

      expect(empty.ladderSpan, 0);
      expect(single.ladderSpan, 0);

      empty.dispose();
      single.dispose();
    });
  });

  group('AccumulatorBarrierDragController ladder updates', () {
    test('applies a new ladder immediately when idle', () {
      final AccumulatorBarrierDragController controller =
          AccumulatorBarrierDragController(steps: _ladder)
            ..steps = _tightLadder;

      expect(controller.steps, _tightLadder);

      controller.dispose();
    });

    test('holds a ladder that arrives mid-drag until the drag ends', () {
      int notifications = 0;
      final AccumulatorBarrierDragController controller =
          AccumulatorBarrierDragController(steps: _ladder)
            ..publishGeometry(_geometry())
            ..addListener(() => notifications++)
            ..beginDrag(AccumulatorBarrierSide.high);

      notifications = 0;
      controller.steps = _tightLadder;

      // Snap targets must not move under the finger.
      expect(controller.steps, _ladder);
      expect(notifications, 0);

      controller.endDrag(commit: false);
      expect(controller.steps, _tightLadder);

      controller.dispose();
    });

    test('keeps only the newest ladder held back during a drag', () {
      final AccumulatorBarrierDragController controller =
          AccumulatorBarrierDragController(steps: _ladder)
            ..beginDrag(AccumulatorBarrierSide.low)
            ..steps = _tightLadder
            ..steps = const <AccumulatorGrowthRateStep>[]
            ..endDrag(commit: false);

      expect(controller.steps, isEmpty);

      controller.dispose();
    });

    test('a committed drag still picks up the held-back ladder', () {
      final AccumulatorBarrierDragController controller =
          AccumulatorBarrierDragController(steps: _ladder)
            ..publishGeometry(_geometry())
            ..beginDrag(AccumulatorBarrierSide.high)
            ..updateDrag(_ladder[0])
            ..steps = _tightLadder
            ..endDrag(commit: true);

      expect(controller.steps, _tightLadder);
      // The preview is still latched waiting for the host's commit.
      expect(controller.previewStep, _ladder[0]);

      controller.dispose();
    });
  });
}
