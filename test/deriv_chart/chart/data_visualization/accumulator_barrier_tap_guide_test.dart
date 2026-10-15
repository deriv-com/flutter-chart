import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/barriers/accumulators_barriers/accumulator_barrier_overlay.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/barriers/accumulators_barriers/accumulator_barrier_geometry.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/barriers/accumulators_barriers/accumulator_barrier_tap_guide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The one-time hint that the band can be tapped.
const double _canvasSize = 400;

const Color _barrierColor = Color(0xFF2C9AFF);

const List<AccumulatorGrowthRateStep> _ladder = <AccumulatorGrowthRateStep>[
  AccumulatorGrowthRateStep(growthRate: 0.01, barrierSpotDistance: 100),
  AccumulatorGrowthRateStep(growthRate: 0.03, barrierSpotDistance: 50),
];

/// Band centred on quote 100, barriers at y=50 and y=150.
AccumulatorBarrierGeometry _geometry() => AccumulatorBarrierGeometry(
      barrierX: 100,
      rightEdgeX: 400,
      highBarrierY: 50,
      lowBarrierY: 150,
      committedBarrierSpotDistance: 50,
    );

void main() {
  group('where it sits', () {
    test('is inset from the band\'s top-left corner', () {
      final Offset center = accumulatorTapGuideCenter(
        bandLeft: 100,
        bandTop: 50,
        bandBottom: 150,
      );

      // The badge's box starts one inset in from the corner, so its centre is
      // a further half-badge along each axis.
      const double expected =
          accumulatorTapGuideInset + accumulatorTapGuideSize / 2;
      expect(center, const Offset(100 + expected, 50 + expected));
    });

    test('does not follow the band as it grows', () {
      // Anchored to the top-left, so a wider band leaves it where it was
      // rather than carrying it down with the midpoint.
      expect(
        accumulatorTapGuideCenter(bandLeft: 100, bandTop: 50, bandBottom: 350),
        accumulatorTapGuideCenter(bandLeft: 100, bandTop: 50, bandBottom: 150),
      );
    });

    test('centres itself rather than overhang a band too short to hold it', () {
      // 20px of band for a 32px badge: inset from the top it would cross the
      // lower barrier, which is the one thing the hint must not obscure.
      final Offset center = accumulatorTapGuideCenter(
        bandLeft: 100,
        bandTop: 50,
        bandBottom: 70,
      );

      expect(center.dy, 60);
    });
  });

  group('when it shows', () {
    test('is off by default, so a consumer opts in', () {
      expect(
          AccumulatorBarrierController(steps: _ladder).showTapGuide, isFalse);
    });

    test('repaints when it is turned on and off', () {
      final AccumulatorBarrierController controller =
          AccumulatorBarrierController(steps: _ladder);
      addTearDown(controller.dispose);

      int notifications = 0;
      controller.addListener(() => notifications++);

      controller.showTapGuide = true;
      expect(controller.showTapGuide, isTrue);
      expect(notifications, 1);

      // Setting what it already is must not repaint.
      controller.showTapGuide = true;
      expect(notifications, 1);
    });

    test('a consumer cannot bring it back after the tap that answered it', () {
      final AccumulatorBarrierController controller =
          AccumulatorBarrierController(
        steps: _ladder,
        showTapGuide: true,
      );
      addTearDown(controller.dispose);

      controller.retireTapGuide();

      // The band republishes on every tick, and the consumer goes on sending
      // the old value until its own state catches up — which must not flick
      // the hint back on over the control the tap just opened.
      controller.showTapGuide = true;
      expect(controller.showTapGuide, isFalse);
    });

    test('a consumer that sends false can show it again later', () {
      final AccumulatorBarrierController controller =
          AccumulatorBarrierController(steps: _ladder, showTapGuide: true);
      addTearDown(controller.dispose);

      controller
        ..retireTapGuide()
        // Catching up is what releases the latch, so the hint is still the
        // consumer's to re-arm — for a different account, say.
        ..showTapGuide = false
        ..showTapGuide = true;

      expect(controller.showTapGuide, isTrue);
    });
  });

  group('what it draws', () {
    /// Paints one frame of the hint and reads the pixels back.
    ///
    /// The style comes from the real default rather than a literal, so these
    /// read what the chart actually draws.
    Future<Color> Function(Offset) painted(
      double pulse, {
      String? label,
      Size size = const Size(80, 80),
    }) {
      const AccumulatorBarrierStyle style = AccumulatorBarrierStyle();
      final ui.PictureRecorder recorder = ui.PictureRecorder();

      paintAccumulatorTapGuide(
        Canvas(recorder),
        center: const Offset(40, 40),
        color: _barrierColor,
        pulse: pulse,
        label: label,
        labelBackgroundColor: style.tapGuideLabelBackgroundColor,
        labelStyle: style.tapGuideLabelStyle,
      );

      final Future<ByteData?> pixels = recorder
          .endRecording()
          .toImage(size.width.toInt(), size.height.toInt())
          .then((ui.Image image) =>
              image.toByteData(format: ui.ImageByteFormat.rawRgba));

      return (Offset at) async {
        final ByteData data = (await pixels)!;
        final int i =
            ((at.dy.toInt() * size.width.toInt()) + at.dx.toInt()) * 4;
        return Color.fromARGB(
          data.getUint8(i + 3),
          data.getUint8(i),
          data.getUint8(i + 1),
          data.getUint8(i + 2),
        );
      };
    }

    /// Alpha of the halo at each whole radius just outside the disc.
    Future<List<int>> halo(double pulse) async {
      final Future<Color> Function(Offset) pixel = painted(pulse);
      final List<int> alphas = <int>[];
      for (int radius = 11; radius <= 17; radius++) {
        alphas.add((await pixel(Offset(40, 40.0 - radius))).alpha);
      }
      return alphas;
    }

    /// How far out the brightest part of the halo is.
    int brightestRadius(List<int> alphas) =>
        11 + alphas.indexOf(alphas.reduce(math.max));

    test('puts a pale hand on a disc in the barrier colour', () async {
      final Future<Color> Function(Offset) pixel = painted(0);

      // Counted over the disc rather than probed at one point: the hand is
      // tilted and full of gaps, so any single pixel can land on a seam.
      int pale = 0;
      int disc = 0;
      for (int dy = -8; dy <= 8; dy++) {
        for (int dx = -8; dx <= 8; dx++) {
          if (dx * dx + dy * dy > 64) {
            continue;
          }
          final Color at = await pixel(Offset(40.0 + dx, 40.0 + dy));
          if (math.min(math.min(at.red, at.green), at.blue) > 0xE0) {
            pale++;
          } else if (at == _barrierColor) {
            disc++;
          }
        }
      }

      expect(pale, greaterThan(20), reason: 'the hand should be drawn');
      expect(disc, greaterThan(pale),
          reason: 'and sit on the disc rather than swallow it');

      // Eight across is still inside the 10px disc but clear of the hand, at
      // any angle: turning it about its own centre cannot push it further out.
      expect(await pixel(const Offset(48, 40)), _barrierColor);
    });

    test('leaves nothing outside the halo', () async {
      // The badge is 32px across, so 20 out from the centre is past even the
      // widest ring and must be untouched.
      expect((await painted(0)(const Offset(40, 60))).alpha, 0);
    });

    test('sends each ring travelling out from the disc', () async {
      // At the top of a cycle a ring is launching, so the halo is brightest
      // right against the disc. A quarter later that ring has moved out.
      // Comparing the two is what separates a ring that travels from one
      // drawn at a fixed radius and merely faded.
      expect(brightestRadius(await halo(0)),
          lessThan(brightestRadius(await halo(0.25))));
    });

    test('keeps the halo moving through the cycle', () async {
      expect(await halo(0.1), isNot(equals(await halo(0.4))));
    });

    test('fades a ring as it goes, so it never outshines the disc', () async {
      expect((await halo(0.5)).every((int alpha) => alpha < 0xFF), isTrue);
    });

    test('paints no label when the consumer supplies none', () async {
      // The chart has no copy of its own, so without one it draws the badge
      // alone rather than inventing a string it cannot translate.
      final Future<Color> Function(Offset) pixel =
          painted(0, size: const Size(200, 80));

      for (double x = 57; x < 200; x++) {
        expect((await pixel(Offset(x, 40))).alpha, 0,
            reason: 'nothing should sit beside the badge at x=$x');
      }
    });

    test('puts the label on a pill beside the badge', () async {
      const AccumulatorBarrierStyle style = AccumulatorBarrierStyle();
      final Future<Color> Function(Offset) pixel =
          painted(0, label: 'Tap to adjust', size: const Size(200, 80));

      // Clear of the badge's 32px box, which ends at x=56, plus the 4px gap.
      expect(await pixel(const Offset(62, 40)),
          isNot(equals(const Color(0x00000000))));

      // Counted rather than probed: the text sits on the pill, so a single
      // point can land on a glyph instead of the fill.
      int fill = 0;
      for (double x = 61; x < 110; x++) {
        if (await pixel(Offset(x, 34)) == style.tapGuideLabelBackgroundColor) {
          fill++;
        }
      }
      expect(fill, greaterThan(20), reason: 'the pill should be drawn');
    });

    test('keeps the text clear of the pill it sits on', () async {
      const AccumulatorBarrierStyle style = AccumulatorBarrierStyle();
      final Future<Color> Function(Offset) pixel =
          painted(0, label: 'Tap to adjust', size: const Size(200, 80));

      // Counted from the first pixel of fill rather than from a computed edge:
      // the pill's cap is a curve, so its outermost column is antialiased and
      // never matches the fill exactly.
      int padding = 0;
      bool inside = false;
      for (double x = 58; x < 110; x++) {
        if (await pixel(Offset(x, 40)) == style.tapGuideLabelBackgroundColor) {
          inside = true;
          padding++;
        } else if (inside) {
          break;
        }
      }

      // Enough that the first glyph is not pressed against the edge. The design's
      // own 4px read as cramped on screen at this size.
      expect(padding, greaterThanOrEqualTo(6),
          reason: 'the label should have room on either side of it');
    });

    test('leaves the badge itself alone', () async {
      // The label is a sibling, not a decoration on the disc: whatever it does,
      // the hand and its halo must look the same.
      final Future<Color> Function(Offset) bare =
          painted(0, size: const Size(200, 80));
      final Future<Color> Function(Offset) labelled =
          painted(0, label: 'Tap to adjust', size: const Size(200, 80));

      for (double x = 24; x <= 56; x++) {
        expect(await labelled(Offset(x, 40)), await bare(Offset(x, 40)),
            reason: 'the badge should be unchanged at x=$x');
      }
    });
  });

  testWidgets('a tap retires the hint without waiting for the consumer',
      (WidgetTester tester) async {
    int taps = 0;
    final AccumulatorBarrierController controller =
        AccumulatorBarrierController(
      steps: _ladder,
      showTapGuide: true,
      onTap: () => taps++,
    )..publishGeometry(_geometry());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: _canvasSize,
            height: _canvasSize,
            child: AccumulatorBarrierOverlay(
              controller: controller,
              onInteractionChanged: () {},
            ),
          ),
        ),
      ),
    );

    final Offset origin =
        tester.getTopLeft(find.byType(AccumulatorBarrierOverlay));
    await tester.tapAt(origin + const Offset(250, 100));
    await tester.pump();

    expect(taps, 1);
    // Gone on the tap itself: the consumer's own flag arrives a round-trip
    // later, by which time the hint would be over the control it opened.
    expect(controller.showTapGuide, isFalse);
  });
}
