import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/barriers/accumulators_barriers/accumulator_barrier_drag_overlay.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/barriers/accumulators_barriers/accumulator_barrier_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Canvas is 400x400 with one quote unit per pixel, so `quote = 200 - y`.
const double _canvasSize = 400;

double _quoteFromY(double y) => 200 - y;

const List<AccumulatorGrowthRateStep> _ladder = <AccumulatorGrowthRateStep>[
  AccumulatorGrowthRateStep(growthRate: 0.01, barrierSpotDistance: 100),
  AccumulatorGrowthRateStep(growthRate: 0.03, barrierSpotDistance: 50),
  AccumulatorGrowthRateStep(growthRate: 0.05, barrierSpotDistance: 20),
];

/// Band centred on quote 100 (y = 100), barriers 50 away: y=50 and y=150.
AccumulatorBarrierGeometry _geometry() => AccumulatorBarrierGeometry(
      barrierX: 100,
      rightEdgeX: 400,
      highBarrierY: 50,
      lowBarrierY: 150,
      highGripRect: const Rect.fromLTWH(185, 44, 31, 12),
      lowGripRect: const Rect.fromLTWH(185, 144, 31, 12),
      bandCenterQuote: 100,
      committedBarrierSpotDistance: 50,
    );

/// Runs out the clock on a committed drag, which both clears the controller's
/// pending timer and asserts the preview is dropped when no commit lands.
Future<void> _letTheCommitTimeOut(
  WidgetTester tester,
  AccumulatorBarrierDragController controller,
) async {
  await tester.pump(controller.commitTimeout + const Duration(seconds: 1));
  expect(controller.previewStep, isNull);
}

void main() {
  late AccumulatorBarrierDragController controller;
  late List<double> updates;
  late List<double> commits;
  late int beginCount;
  late int finishCount;

  Future<void> pumpOverlay(
    WidgetTester tester, {
    double? graphAreaWidth,
    Widget? below,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: _canvasSize,
            height: _canvasSize,
            child: Stack(
              children: <Widget>[
                if (below != null) Positioned.fill(child: below),
                AccumulatorBarrierDragOverlay(
                  controller: controller,
                  quoteFromCanvasY: _quoteFromY,
                  graphAreaWidth: graphAreaWidth,
                  onInteractionChanged: () {},
                  onDragBegin: () => beginCount++,
                  onDragFinish: () => finishCount++,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  setUp(() {
    updates = <double>[];
    commits = <double>[];
    beginCount = 0;
    finishCount = 0;
    controller = AccumulatorBarrierDragController(
      steps: _ladder,
      onDragUpdate: (AccumulatorGrowthRateStep step) =>
          updates.add(step.growthRate),
      onDragEnd: (AccumulatorGrowthRateStep step) =>
          commits.add(step.growthRate),
    )..publishGeometry(_geometry());
  });

  tearDown(() => controller.dispose());

  testWidgets('dragging the high grip outward snaps to a lower growth rate',
      (WidgetTester tester) async {
    await pumpOverlay(tester);

    // Grab the high grip (y=50) and pull it up to y=10 — 90 quote units from
    // the band centre, nearest the 100-distance rung.
    final Offset grip = tester.getTopLeft(
          find.byType(AccumulatorBarrierDragOverlay),
        ) +
        const Offset(200, 50);

    final TestGesture gesture = await tester.startGesture(grip);
    expect(controller.isDragging, isTrue);
    expect(beginCount, 1);

    await gesture.moveBy(const Offset(0, -40));
    await tester.pump();

    expect(controller.previewStep?.growthRate, 0.01);
    expect(updates, <double>[0.01]);

    await gesture.up();
    await tester.pump();

    expect(controller.isDragging, isFalse);
    expect(commits, <double>[0.01]);
    expect(finishCount, 1);
    // The band keeps showing the committed step while the host round-trips.
    expect(controller.previewStep?.growthRate, 0.01);

    await _letTheCommitTimeOut(tester, controller);
  });

  testWidgets('dragging the low grip inward snaps to a higher growth rate',
      (WidgetTester tester) async {
    await pumpOverlay(tester);

    final Offset grip = tester.getTopLeft(
          find.byType(AccumulatorBarrierDragOverlay),
        ) +
        const Offset(200, 150);

    final TestGesture gesture = await tester.startGesture(grip);
    // Up 30px: the low barrier moves to y=120, i.e. 20 from the centre.
    await gesture.moveBy(const Offset(0, -30));
    await tester.pump();

    expect(controller.previewStep?.growthRate, 0.05);

    await gesture.up();
    await tester.pump();

    expect(commits, <double>[0.05]);

    await _letTheCommitTimeOut(tester, controller);
  });

  testWidgets('a press away from the barriers starts no drag',
      (WidgetTester tester) async {
    await pumpOverlay(tester);

    final TestGesture gesture = await tester.startGesture(
      tester.getTopLeft(find.byType(AccumulatorBarrierDragOverlay)) +
          const Offset(200, 100),
    );
    await gesture.moveBy(const Offset(0, -40));
    await tester.pump();

    expect(controller.isDragging, isFalse);
    expect(beginCount, 0);
    expect(updates, isEmpty);

    await gesture.up();
  });

  testWidgets('the barrier drag wins over a competing pan below it',
      (WidgetTester tester) async {
    final List<String> panEvents = <String>[];

    await pumpOverlay(
      tester,
      below: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) => panEvents.add('start'),
        onPanUpdate: (_) => panEvents.add('update'),
      ),
    );

    final Offset grip = tester.getTopLeft(
          find.byType(AccumulatorBarrierDragOverlay),
        ) +
        const Offset(200, 50);

    final TestGesture gesture = await tester.startGesture(grip);
    await gesture.moveBy(const Offset(0, -40));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(controller.previewStep?.growthRate, 0.01);
    expect(panEvents, isEmpty);

    // …while a press away from the barriers still reaches the pan below.
    final TestGesture elsewhere = await tester.startGesture(
      tester.getTopLeft(find.byType(AccumulatorBarrierDragOverlay)) +
          const Offset(200, 100),
    );
    await elsewhere.moveBy(const Offset(0, -40));
    await tester.pump();
    await elsewhere.up();
    await tester.pump();

    expect(panEvents, isNotEmpty);

    await _letTheCommitTimeOut(tester, controller);
  });

  testWidgets('presses over the quote-label strip are left to the Y axis',
      (WidgetTester tester) async {
    await pumpOverlay(tester, graphAreaWidth: 150);

    // On the high barrier line, but to the right of the plotting area.
    final TestGesture gesture = await tester.startGesture(
      tester.getTopLeft(find.byType(AccumulatorBarrierDragOverlay)) +
          const Offset(300, 50),
    );
    await gesture.moveBy(const Offset(0, -40));
    await tester.pump();

    expect(controller.isDragging, isFalse);

    await gesture.up();
  });

  testWidgets('a disabled controller ignores the barriers entirely',
      (WidgetTester tester) async {
    controller.enabled = false;
    await pumpOverlay(tester);

    final TestGesture gesture = await tester.startGesture(
      tester.getTopLeft(find.byType(AccumulatorBarrierDragOverlay)) +
          const Offset(200, 50),
    );
    await gesture.moveBy(const Offset(0, -40));
    await tester.pump();

    expect(controller.isDragging, isFalse);

    await gesture.up();
  });
}
