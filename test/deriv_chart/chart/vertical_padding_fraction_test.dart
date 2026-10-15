import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/basic_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/main_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/y_axis/y_axis_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// The vertical zoom the consumer asks for, and what the chart does with it.
///
/// It sets the scale rather than fixing it, so the interesting cases are all
/// about *when* it is re-applied: on a change, so a consumer can re-scale on a
/// trade-type switch, but never on an unrelated rebuild, which would fight a
/// user mid-drag.
void main() {
  final List<Tick> ticks = <Tick>[
    Tick(epoch: 1000, quote: 10),
    Tick(epoch: 2000, quote: 20),
    Tick(epoch: 3000, quote: 30),
  ];

  late AnimationController xAxisAnimationController;

  Widget buildChart({double? verticalPaddingFraction}) {
    YAxisConfig.instance.setLabelWidth(60);

    final XAxisModel xAxisModel = XAxisModel(
      entries: ticks,
      granularity: 1000,
      animationController: xAxisAnimationController,
      isLive: false,
      snapMarkersToIntervals: false,
      maxCurrentTickOffset: 150,
    )
      // Normally set by the XAxis widget during layout.
      ..width = 800
      ..graphAreaWidth = 740;

    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<XAxisModel>.value(value: xAxisModel),
          Provider<ChartTheme>.value(value: ChartDefaultDarkTheme()),
          Provider<ChartConfig>.value(
            value: const ChartConfig(granularity: 1000),
          ),
          Provider<ChartScaleModel>.value(
            value: const ChartScaleModel(granularity: 1000, msPerPx: 1000),
          ),
        ],
        child: GestureManager(
          child: MainChart(
            mainSeries: LineSeries(ticks),
            crosshairVariant: CrosshairVariant.smallScreen,
            showCrosshair: false,
            verticalPaddingFraction: verticalPaddingFraction,
          ),
        ),
      ),
    );
  }

  /// The scale the chart is actually painting at.
  double scaleOf(WidgetTester tester) => tester
      .state<BasicChartState<MainChart>>(find.byType(MainChart))
      .verticalPaddingFraction;

  /// Stands in for the user dragging the quote labels.
  void dragQuoteLabels(WidgetTester tester, double fraction) {
    tester
        .state<BasicChartState<MainChart>>(find.byType(MainChart))
        .verticalPaddingFraction = fraction;
  }

  setUp(() {
    xAxisAnimationController = AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 100),
    );
  });

  tearDown(() {
    xAxisAnimationController.dispose();
  });

  group('verticalPaddingFraction', () {
    testWidgets('leaves the default alone when the consumer asks for nothing',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildChart());

      expect(scaleOf(tester), 0.1);
    });

    testWidgets('takes the consumer\'s scale on mount',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildChart(verticalPaddingFraction: 0.05));

      expect(scaleOf(tester), 0.05);
    });

    testWidgets('re-applies when the consumer asks for a different scale',
        (WidgetTester tester) async {
      // What a trade-type switch looks like from here: the chart is not
      // recreated, so only a prop change can re-scale it.
      await tester.pumpWidget(buildChart(verticalPaddingFraction: 0.3));
      expect(scaleOf(tester), 0.3);

      await tester.pumpWidget(buildChart(verticalPaddingFraction: 0.05));

      expect(scaleOf(tester), 0.05);
    });

    testWidgets('leaves a dragged scale alone when the prop has not changed',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildChart(verticalPaddingFraction: 0.05));
      dragQuoteLabels(tester, 0.4);

      // An unrelated rebuild — a new tick, a theme change — must not snap the
      // axis back out from under the user.
      await tester.pumpWidget(buildChart(verticalPaddingFraction: 0.05));

      expect(scaleOf(tester), 0.4);
    });

    testWidgets('lets the consumer clear its scale back to the user\'s',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildChart(verticalPaddingFraction: 0.05));
      dragQuoteLabels(tester, 0.4);

      // Dropping the prop is a change, but there is no scale to apply, so the
      // user's stays.
      await tester.pumpWidget(buildChart());

      expect(scaleOf(tester), 0.4);
    });

    testWidgets('clamps a scale the user could never drag back to',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildChart(verticalPaddingFraction: 0));
      expect(scaleOf(tester), BasicChartState.minVerticalPaddingFraction);

      await tester.pumpWidget(buildChart(verticalPaddingFraction: 1));
      expect(scaleOf(tester), BasicChartState.maxVerticalPaddingFraction);
    });
  });
}
