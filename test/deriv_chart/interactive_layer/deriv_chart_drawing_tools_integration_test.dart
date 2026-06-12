import 'dart:convert';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_behaviours/interactive_layer_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_behaviours/interactive_layer_mobile_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Integration-style tests that mirror how deriv_trader's TradeChart wires
/// drawing tools into the full [DerivChart] widget: a single external
/// [AddOnsRepository] instance reused across symbol switches (reloaded from
/// SharedPreferences), a persistent [InteractiveLayerMobileBehaviour], and
/// `useDrawingToolsV2: true`.
void main() {
  final List<Tick> ticks = <Tick>[
    Tick(epoch: 1000, quote: 10),
    Tick(epoch: 2000, quote: 20),
    Tick(epoch: 3000, quote: 30),
  ];

  String prefsKey(String symbol) => 'addOns_DrawingToolConfig_$symbol';

  String encodedHorizontal(String id) => jsonEncode(
        HorizontalDrawingToolConfig(
          configId: id,
          edgePoints: const <EdgePoint>[EdgePoint(epoch: 2000, quote: 20)],
        ).toJson(),
      );

  Widget app({
    required String symbol,
    required AddOnsRepository<DrawingToolConfig> repo,
    required DrawingTools drawingTools,
    required InteractiveLayerBehaviour behaviour,
  }) =>
      MaterialApp(
        home: Scaffold(
          body: DerivChart(
            // Mirrors TradeChart: full remount of the chart subtree per
            // symbol (same pattern as the marker rebuild fix).
            key: ValueKey<String>('trade_chart_$symbol'),
            mainSeries: LineSeries(ticks),
            granularity: 1000,
            activeSymbol: symbol,
            drawingTools: drawingTools,
            drawingToolsRepo: repo,
            interactiveLayerBehaviour: behaviour,
            useDrawingToolsV2: true,
          ),
        ),
      );

  testWidgets(
      'drawings reload across symbol switches and deletes repaint '
      '(full DerivChart wiring)', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      prefsKey('R_100'): <String>[encodedHorizontal('r100_drawing')],
      prefsKey('R_50'): <String>[encodedHorizontal('r50_drawing')],
    });

    final AddOnsRepository<DrawingToolConfig> repo =
        AddOnsRepository<DrawingToolConfig>(
      createAddOn: (Map<String, dynamic> map) =>
          DrawingToolConfig.fromJson(map),
      sharedPrefKey: 'R_100',
    );
    final DrawingTools drawingTools = DrawingTools();
    final InteractiveLayerBehaviour behaviour =
        InteractiveLayerMobileBehaviour(
      controller: InteractiveLayerController(),
    );

    // Mount for symbol R_100; the async prefs load completes after mount,
    // exactly like TradeChart's initState flow.
    await tester.pumpWidget(app(
      symbol: 'R_100',
      repo: repo,
      drawingTools: drawingTools,
      behaviour: behaviour,
    ));
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    repo.loadFromPrefs(prefs, 'R_100');
    await tester.pump();
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('r100_drawing')),
      findsOneWidget,
      reason: 'R_100 drawings should load on first mount',
    );

    // Switch symbol -> R_50: DerivChart rebuilds with new activeSymbol, the
    // consumer reloads the same repo instance from prefs.
    await tester.pumpWidget(app(
      symbol: 'R_50',
      repo: repo,
      drawingTools: drawingTools,
      behaviour: behaviour,
    ));
    repo.loadFromPrefs(prefs, 'R_50');
    await tester.pump();
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('r50_drawing')),
      findsOneWidget,
      reason: 'R_50 drawings should appear after switching symbol',
    );
    expect(
      find.byKey(const ValueKey<String>('r100_drawing')),
      findsNothing,
      reason: 'R_100 drawings must not leak onto R_50',
    );

    // Switch back -> R_100: drawings must reload.
    await tester.pumpWidget(app(
      symbol: 'R_100',
      repo: repo,
      drawingTools: drawingTools,
      behaviour: behaviour,
    ));
    repo.loadFromPrefs(prefs, 'R_100');
    await tester.pump();
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('r100_drawing')),
      findsOneWidget,
      reason: 'R_100 drawings should reload when switching back',
    );

    // Delete from the repo (what the bottom sheet does) and verify the chart
    // stops painting it.
    repo.removeAt(0);
    await tester.pump();
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('r100_drawing')),
      findsNothing,
      reason: 'deleted drawing must disappear from the chart',
    );

    // Let pending state-change animations run before teardown (the chart has
    // continuous animations, so pumpAndSettle would never settle).
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets(
      'drawings loaded before the chart subtree mounts still appear '
      '(release-mode race)', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      prefsKey('R_100'): <String>[encodedHorizontal('early_drawing')],
    });

    final AddOnsRepository<DrawingToolConfig> repo =
        AddOnsRepository<DrawingToolConfig>(
      createAddOn: (Map<String, dynamic> map) =>
          DrawingToolConfig.fromJson(map),
      sharedPrefKey: 'R_100',
    );

    // Load completes BEFORE the chart is mounted: its notification has no
    // chart listener yet.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    repo.loadFromPrefs(prefs, 'R_100');

    await tester.pumpWidget(app(
      symbol: 'R_100',
      repo: repo,
      drawingTools: DrawingTools(),
      behaviour: InteractiveLayerMobileBehaviour(
        controller: InteractiveLayerController(),
      ),
    ));
    await tester.pump();
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('early_drawing')),
      findsOneWidget,
      reason: 'drawings loaded before mount must appear via initial sync',
    );
  });
}
