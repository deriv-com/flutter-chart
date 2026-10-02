import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/barriers/accumulators_barriers/accumulator_barrier_drag_overlay.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/barriers/accumulators_barriers/accumulator_barrier_geometry.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The band as a tap target, which is what a consumer gets by default: no
/// grips, no dragging, and the control lives in the consumer's own UI.
///
/// The band covers a large part of the chart, so the one thing it must not do
/// is take the pointer away from panning.
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

void main() {
  late AccumulatorBarrierDragController controller;
  late int taps;
  late int presses;
  late List<String> panLog;

  Future<void> pumpOverlay(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: _canvasSize,
            height: _canvasSize,
            child: Stack(
              children: <Widget>[
                // Stands in for the chart's own pan, underneath the overlay.
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (_) => panLog.add('start'),
                    onPanUpdate: (_) => panLog.add('update'),
                  ),
                ),
                AccumulatorBarrierDragOverlay(
                  controller: controller,
                  quoteFromCanvasY: _quoteFromY,
                  onInteractionChanged: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Offset at(WidgetTester tester, Offset local) =>
      tester.getTopLeft(find.byType(AccumulatorBarrierDragOverlay)) + local;

  setUp(() {
    taps = 0;
    presses = 0;
    panLog = <String>[];
    controller = AccumulatorBarrierDragController(
      steps: _ladder,
      onTap: () => taps++,
      onPressStart: () => presses++,
    )..publishGeometry(_geometry());
  });

  tearDown(() => controller.dispose());

  testWidgets('a tap inside the band is reported', (WidgetTester tester) async {
    await pumpOverlay(tester);

    // Mid-band, nowhere near either line — the whole box is the target.
    await tester.tapAt(at(tester, const Offset(250, 100)));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('a tap just outside a barrier line still counts',
      (WidgetTester tester) async {
    await pumpOverlay(tester);

    // The margin on the lines keeps the edges easy to hit.
    await tester.tapAt(at(tester, const Offset(250, 46)));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('the press is announced before the gesture is known to be a tap',
      (WidgetTester tester) async {
    await pumpOverlay(tester);

    // A consumer that decides what a gesture means from a document listener in
    // the capture phase has already acted by the time the tap is reported, so
    // the press is what it has to hear. See `onPressStart`.
    final TestGesture gesture =
        await tester.startGesture(at(tester, const Offset(250, 100)));
    await tester.pump();

    expect(presses, 1);
    expect(taps, 0);

    await gesture.up();
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('a press that turns into a pan is still announced',
      (WidgetTester tester) async {
    await pumpOverlay(tester);

    // The consumer is told the gesture started on the band; that it ended up a
    // pan is the consumer's to interpret.
    final TestGesture gesture =
        await tester.startGesture(at(tester, const Offset(250, 100)));
    await gesture.moveBy(const Offset(0, 60));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(presses, 1);
    expect(taps, 0);
  });

  testWidgets('a press outside the band is not announced',
      (WidgetTester tester) async {
    await pumpOverlay(tester);

    final TestGesture gesture =
        await tester.startGesture(at(tester, const Offset(250, 300)));
    await tester.pump();

    expect(presses, 0);

    await gesture.up();
    await tester.pump();
  });

  testWidgets('a tap outside the band is ignored', (WidgetTester tester) async {
    await pumpOverlay(tester);

    await tester.tapAt(at(tester, const Offset(250, 300)));
    await tester.pump();

    expect(taps, 0);
  });

  testWidgets('a press that becomes a drag pans the chart instead',
      (WidgetTester tester) async {
    await pumpOverlay(tester);

    // Starting inside the band must not cost the user the pan: the band is far
    // too big to swallow every gesture that begins on it.
    final TestGesture gesture =
        await tester.startGesture(at(tester, const Offset(250, 100)));
    await gesture.moveBy(const Offset(0, 60));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(panLog, isNotEmpty);
    expect(taps, 0);
  });

  testWidgets('nothing is dragged, whatever the pointer does',
      (WidgetTester tester) async {
    await pumpOverlay(tester);

    final TestGesture gesture =
        await tester.startGesture(at(tester, const Offset(250, 50)));
    await gesture.moveBy(const Offset(0, -60));
    await tester.pump();

    expect(controller.isDragging, isFalse);
    expect(controller.previewStep, isNull);

    await gesture.up();
    await tester.pump();
  });

  testWidgets('hovering the band highlights it', (WidgetTester tester) async {
    await pumpOverlay(tester);

    final TestGesture pointer =
        await tester.createGesture(kind: PointerDeviceKind.mouse);
    await pointer.addPointer(location: Offset.zero);
    addTearDown(pointer.removePointer);

    await pointer.moveTo(at(tester, const Offset(250, 100)));
    await tester.pump();

    expect(controller.isHighlighted, isTrue);

    await pointer.moveTo(at(tester, const Offset(250, 300)));
    await tester.pump();

    expect(controller.isHighlighted, isFalse);
  });
}
