import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/barriers/accumulators_barriers/accumulators_indicator_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Where the ± values land as they grow while the growth rate is being changed.
///
/// The band is the thing the user is reading, so the one thing the labels must
/// not do is grow onto it.
const String _text = '+1.2733';

const TextStyle _resting = TextStyle(fontSize: 12);
const TextStyle _emphasised =
    TextStyle(fontSize: 22, fontWeight: FontWeight.bold);

/// The label's resting position: 30px right of the barrier, 10px clear of it.
const Offset _aboveBarrier = Offset(130, 190);
const Offset _belowBarrier = Offset(130, 310);

void main() {
  late TextPainter resting;
  late TextPainter emphasised;

  setUp(() {
    resting = makeTextPainter(_text, _resting);
    emphasised = makeTextPainter(_text, _emphasised);
  });

  test('at rest it sits exactly where centring it would', () {
    for (final bool growsUpwards in <bool>[true, false]) {
      final Offset topLeft = barrierLabelTopLeft(
        resting: resting,
        painter: resting,
        restingCenter: _aboveBarrier,
        growsUpwards: growsUpwards,
      );

      // Changing the anchor must not move the label when nothing is emphasised.
      expect(
        topLeft,
        Offset(_aboveBarrier.dx - resting.width / 2,
            _aboveBarrier.dy - resting.height / 2),
      );
    }
  });

  test('the left edge does not move as it grows', () {
    final double restingLeft = barrierLabelTopLeft(
      resting: resting,
      painter: resting,
      restingCenter: _aboveBarrier,
      growsUpwards: true,
    ).dx;

    expect(
      barrierLabelTopLeft(
        resting: resting,
        painter: emphasised,
        restingCenter: _aboveBarrier,
        growsUpwards: true,
      ).dx,
      restingLeft,
    );
  });

  group('above its barrier', () {
    test('keeps its numerals on the resting baseline', () {
      double baselineOf(TextPainter painter) =>
          barrierLabelTopLeft(
            resting: resting,
            painter: painter,
            restingCenter: _aboveBarrier,
            growsUpwards: true,
          ).dy +
          painter.computeDistanceToActualBaseline(TextBaseline.alphabetic);

      expect(baselineOf(emphasised), closeTo(baselineOf(resting), 0.01));
    });

    test('grows upwards, away from the line', () {
      expect(
        barrierLabelTopLeft(
          resting: resting,
          painter: emphasised,
          restingCenter: _aboveBarrier,
          growsUpwards: true,
        ).dy,
        lessThan(barrierLabelTopLeft(
          resting: resting,
          painter: resting,
          restingCenter: _aboveBarrier,
          growsUpwards: true,
        ).dy),
      );
    });
  });

  group('below its barrier', () {
    test('keeps the gap above it, so it cannot reach the line', () {
      // Its top edge is the one facing the barrier, so that is what is pinned.
      expect(
        barrierLabelTopLeft(
          resting: resting,
          painter: emphasised,
          restingCenter: _belowBarrier,
          growsUpwards: false,
        ).dy,
        _belowBarrier.dy - resting.height / 2,
      );
    });

    test('grows downwards', () {
      final Offset topLeft = barrierLabelTopLeft(
        resting: resting,
        painter: emphasised,
        restingCenter: _belowBarrier,
        growsUpwards: false,
      );

      expect(topLeft.dy + emphasised.height,
          greaterThan(_belowBarrier.dy + resting.height / 2));
    });
  });

  test('neither label crosses its barrier at full emphasis', () {
    const double highBarrierY = 200;
    const double lowBarrierY = 300;

    final Offset high = barrierLabelTopLeft(
      resting: resting,
      painter: emphasised,
      restingCenter: const Offset(130, highBarrierY - 10),
      growsUpwards: true,
    );
    final Offset low = barrierLabelTopLeft(
      resting: resting,
      painter: emphasised,
      restingCenter: const Offset(130, lowBarrierY + 10),
      growsUpwards: false,
    );

    // The regression this guards: at 22px a centred anchor put both labels
    // across their own lines.
    expect(high.dy + emphasised.height, lessThanOrEqualTo(highBarrierY));
    expect(low.dy, greaterThanOrEqualTo(lowBarrierY));
  });
}
