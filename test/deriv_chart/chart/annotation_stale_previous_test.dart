import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/barriers/horizontal_barrier/horizontal_barrier.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/barrier_objects.dart';
import 'package:flutter_test/flutter_test.dart';

/// What an annotation is allowed to animate from.
///
/// It eases from where it last was, so a previous position that has scrolled
/// off screen turns the transition into a sweep across the whole chart rather
/// than a step. Coming back from the background is exactly that: frames stop
/// while the app is away, so the position left behind is as old as the absence
/// and the whole backlog lands in one rebuild.
void main() {
  /// The Accumulators band at [epoch], centred on [quote].
  AccumulatorIndicator bandAt(int epoch, {double quote = 100}) =>
      AccumulatorIndicator(
        Tick(epoch: epoch, quote: quote),
        lowBarrier: quote - 1,
        highBarrier: quote + 1,
        lowBarrierDisplay: '${quote - 1}',
        highBarrierDisplay: '${quote + 1}',
        barrierSpotDistance: '1',
        barrierEpoch: epoch,
      );

  /// Moves the band on to [next], the way a rebuild does.
  AccumulatorIndicator advance(
    AccumulatorIndicator band,
    AccumulatorIndicator next,
  ) {
    next.didUpdate(band);
    return next;
  }

  test('a previous position still on screen is kept, so the move animates', () {
    final AccumulatorIndicator moved =
        advance(bandAt(1000), bandAt(2000, quote: 101));

    // One tick on, with the viewport covering both: easing between them reads
    // as a single step.
    moved.onUpdate(0, 5000);

    expect(moved.previousObject, isNotNull);
  });

  test('a previous position that has scrolled out of view is dropped', () {
    final AccumulatorIndicator moved =
        advance(bandAt(1000), bandAt(500000, quote: 101));

    // Minutes of ticks arrived at once and the chart scrolled past where the
    // band used to be, so there is nothing on screen to ease from.
    moved.onUpdate(400000, 500000);

    expect(moved.previousObject, isNull);
  });

  test('dropping it leaves the band itself on range', () {
    final AccumulatorIndicator moved =
        advance(bandAt(1000), bandAt(500000, quote: 101));

    moved.onUpdate(400000, 500000);

    expect(moved.isOnRange, isTrue);
  });

  test('an annotation with no epoch bounds of its own is left alone', () {
    // A plain horizontal barrier spans the chart rather than sitting at a point
    // in time — its object leaves `rightEpoch` null — so there is no such thing
    // as it scrolling out of view.
    final HorizontalBarrier barrier = HorizontalBarrier(100)
      ..previousObject = const BarrierObject(quote: 100);

    barrier.onUpdate(400000, 500000);

    expect(barrier.previousObject, isNotNull);
  });
}
