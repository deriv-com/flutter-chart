import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/barriers/accumulators_barriers/accumulator_barrier_geometry.dart';
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

/// A realistic ladder: the accumulators barrier offsets the API returns are
/// nearly flat across growth rates, so the rungs sit ~6% apart rather than the
/// 2x-per-rate spread a naive model would assume.
const List<AccumulatorGrowthRateStep> _tightLadder =
    <AccumulatorGrowthRateStep>[
  AccumulatorGrowthRateStep(growthRate: 0.01, barrierSpotDistance: 0.6256),
  AccumulatorGrowthRateStep(growthRate: 0.03, barrierSpotDistance: 0.5484),
  AccumulatorGrowthRateStep(growthRate: 0.05, barrierSpotDistance: 0.4966),
];

AccumulatorBarrierGeometry _geometry({double committedSpotDistance = 3}) =>
    AccumulatorBarrierGeometry(
      barrierX: 100,
      rightEdgeX: 300,
      highBarrierY: 100,
      lowBarrierY: 200,
      committedBarrierSpotDistance: committedSpotDistance,
    );

AccumulatorIndicator _buildIndicator({
  AccumulatorBarrierController? controller,
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
      controller: controller,
    );

void main() {
  group('whether the band is interactive', () {
    test('a ladder with nothing to pick between is not', () {
      final AccumulatorBarrierController single = AccumulatorBarrierController(
        steps: <AccumulatorGrowthRateStep>[_ladder.first],
      );
      final AccumulatorBarrierController none = AccumulatorBarrierController();

      // A band that opens a picker holding one value is worse than an inert one.
      expect(single.enabled, isFalse);
      expect(none.enabled, isFalse);

      single.dispose();
      none.dispose();
    });

    test('becomes interactive once a real ladder arrives', () {
      final AccumulatorBarrierController controller =
          AccumulatorBarrierController(
        steps: <AccumulatorGrowthRateStep>[_ladder.first],
      );

      expect(controller.enabled, isFalse);

      controller.steps = _ladder;
      expect(controller.enabled, isTrue);

      controller.dispose();
    });

    test('disabling clears anything in flight', () {
      final AccumulatorBarrierController controller =
          AccumulatorBarrierController(steps: _ladder)
            ..publishGeometry(_geometry())
            ..previewGrowthRate(0.01)
            ..setHovered(isHovered: true)
            ..enabled = false;

      expect(controller.previewStep, isNull);
      expect(controller.isHighlighted, isFalse);

      controller.dispose();
    });
  });

  group('previewGrowthRate', () {
    test('shows the band at a rate the consumer picked', () {
      final AccumulatorBarrierController controller =
          AccumulatorBarrierController(steps: _ladder)
            ..publishGeometry(_geometry())
            ..previewGrowthRate(0.05);

      // The consumer owns the control, so this is how the band keeps up with
      // it instead of waiting for the proposal to land.
      expect(controller.previewStep?.growthRate, 0.05);

      controller.dispose();
    });

    test('hands the band back to the model when passed null', () {
      final AccumulatorBarrierController controller =
          AccumulatorBarrierController(steps: _ladder)
            ..publishGeometry(_geometry())
            ..previewGrowthRate(0.05)
            ..previewGrowthRate(null);

      expect(controller.previewStep, isNull);

      controller.dispose();
    });

    test('ignores a rate the ladder does not hold', () {
      final AccumulatorBarrierController controller =
          AccumulatorBarrierController(steps: _ladder)
            ..publishGeometry(_geometry())
            ..previewGrowthRate(0.05)
            ..previewGrowthRate(0.99);

      // Nothing to show, so the model's own barriers take over rather than the
      // band being left on a rate that is no longer selectable.
      expect(controller.previewStep, isNull);

      controller.dispose();
    });

    test('notifies once per change, so the band glides rather than jumps', () {
      int notifications = 0;
      final AccumulatorBarrierController controller =
          AccumulatorBarrierController(steps: _ladder)
            ..publishGeometry(_geometry())
            ..addListener(() => notifications++)
            ..previewGrowthRate(0.05)
            // Same rate again: nothing moved, so nothing to announce.
            ..previewGrowthRate(0.05);

      expect(notifications, 1);

      controller.dispose();
    });
  });

  group('preview transition', () {
    late AccumulatorBarrierController controller;

    setUp(() {
      controller = AccumulatorBarrierController(steps: _ladder)
        ..publishGeometry(_geometry(committedSpotDistance: 3));
    });

    tearDown(() => controller.dispose());

    test('nothing to glide from before the first rung change', () {
      expect(controller.previewTransitionFrom, isNull);
    });

    test('the first rung change glides from the committed band', () {
      controller.previewGrowthRate(0.02);

      expect(controller.previewTransitionFrom, 3);
    });

    test('a settled rung change glides from the previous rung', () {
      controller
        ..previewGrowthRate(0.02)
        // Painter reports the glide finished on the rung it was heading to.
        ..publishRenderedPreviewDistance(4)
        ..previewGrowthRate(0.01);

      expect(controller.previewTransitionFrom, 4);
    });

    test('a rung change mid-glide carries on from where the band is', () {
      controller
        ..previewGrowthRate(0.02)
        // Halfway between the committed 3 and the 4 it was heading to.
        ..publishRenderedPreviewDistance(3.5)
        ..previewGrowthRate(0.01);

      // Not the rung it was leaving, and not the one it was heading to.
      expect(controller.previewTransitionFrom, 3.5);
    });

    test('exposes what was drawn so the chart can glide on from it', () {
      controller
        ..previewGrowthRate(0.01)
        ..publishRenderedPreviewDistance(4.8);

      expect(controller.renderedPreviewDistance, 4.8);
    });

    test('clearing the preview forgets the transition', () {
      controller
        ..previewGrowthRate(0.01)
        ..publishRenderedPreviewDistance(4.8)
        ..clearPreview();

      expect(controller.previewTransitionFrom, isNull);
      expect(controller.renderedPreviewDistance, isNull);
    });
  });

  test('a new ladder is applied straight away', () {
    final AccumulatorBarrierController controller =
        AccumulatorBarrierController(steps: _ladder)..steps = _tightLadder;

    expect(controller.steps, _tightLadder);

    controller.dispose();
  });

  group('AccumulatorIndicator', () {
    test('has no preview without a controller', () {
      expect(_buildIndicator().previewStep, isNull);
    });

    test('ignores the controller once a contract is active', () {
      final AccumulatorBarrierController controller =
          AccumulatorBarrierController(steps: _ladder)
            ..publishGeometry(_geometry())
            ..previewGrowthRate(0.01);

      expect(
        _buildIndicator(
          controller: controller,
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

    test('recalculateMinMax follows the preview', () {
      final AccumulatorBarrierController controller =
          AccumulatorBarrierController(steps: _ladder)
            ..publishGeometry(_geometry())
            // Distance 5 around the committed centre of 100 -> 95..105.
            ..previewGrowthRate(0.01);

      final AccumulatorIndicator indicator =
          _buildIndicator(controller: controller)..onUpdate(0, 2000);

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
