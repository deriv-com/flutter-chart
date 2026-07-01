import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/deriv_chart/chart/y_axis/y_axis_config.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_controller.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/crosshair/crosshair_variant.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactable_drawings/interactable_drawing.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_behaviours/interactive_layer_desktop_behaviour.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/enums/state_change_direction.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_states/interactive_normal_state.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_states/interactive_selected_tool_state.dart';
import 'package:deriv_chart/src/models/axis_range.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  final List<Tick> ticks = <Tick>[
    Tick(epoch: 1000, quote: 10),
    Tick(epoch: 2000, quote: 20),
    Tick(epoch: 3000, quote: 30),
  ];

  HorizontalDrawingToolConfig horizontalConfig(String id) =>
      HorizontalDrawingToolConfig(
        configId: id,
        edgePoints: const <EdgePoint>[EdgePoint(epoch: 2000, quote: 20)],
      );

  AddOnsRepository<DrawingToolConfig> createRepo() =>
      AddOnsRepository<DrawingToolConfig>(
        createAddOn: (Map<String, dynamic> map) =>
            DrawingToolConfig.fromJson(map),
        sharedPrefKey: 'test_symbol',
      );

  late AnimationController xAxisAnimationController;

  Widget buildLayer({
    required Repository<DrawingToolConfig> repo,
    required InteractiveLayerBehaviour behaviour,
  }) {
    YAxisConfig.instance.setLabelWidth(60);

    final DataSeries<Tick> series = LineSeries(ticks);
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
        ],
        child: InteractiveLayer(
          drawingTools: DrawingTools(),
          series: series,
          chartConfig: const ChartConfig(granularity: 1000),
          quoteToCanvasY: (double quote) => quote,
          quoteFromCanvasY: (double y) => y,
          epochToCanvasX: (int epoch) => epoch.toDouble() / 100,
          epochFromCanvasX: (double x) => (x * 100).toInt(),
          drawingToolsRepo: repo,
          quoteRange: QuoteRange(topQuote: 40, bottomQuote: 0),
          interactiveLayerBehaviour: behaviour,
          crosshairZoomOutAnimation: const AlwaysStoppedAnimation<double>(0),
          crosshairController: CrosshairController(
            xAxisModel: xAxisModel,
            series: series,
            showCrosshair: false,
            crosshairVariant: CrosshairVariant.smallScreen,
          ),
          crosshairVariant: CrosshairVariant.smallScreen,
          showCrosshair: false,
        ),
      ),
    );
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

  group('InteractiveLayer repo sync', () {
    testWidgets(
        'renders drawings already present in the repo before the layer mounts',
        (WidgetTester tester) async {
      final AddOnsRepository<DrawingToolConfig> repo = createRepo()
        // Populated BEFORE the layer is mounted: its notification fires when
        // no listener exists yet (the release-mode symbol-switch scenario).
        ..add(horizontalConfig('pre_mount_drawing'));

      await tester.pumpWidget(buildLayer(
        repo: repo,
        behaviour: InteractiveLayerDesktopBehaviour(),
      ));

      // Allow the post-frame initial sync to run and rebuild.
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('pre_mount_drawing')),
        findsOneWidget,
      );
    });

    testWidgets('adds and removes drawings on repo mutations',
        (WidgetTester tester) async {
      final AddOnsRepository<DrawingToolConfig> repo = createRepo();

      await tester.pumpWidget(buildLayer(
        repo: repo,
        behaviour: InteractiveLayerDesktopBehaviour(),
      ));
      await tester.pump();

      repo.add(horizontalConfig('drawing_1'));
      await tester.pump();
      expect(find.byKey(const ValueKey<String>('drawing_1')), findsOneWidget);

      repo.removeAt(0);
      await tester.pump();
      expect(find.byKey(const ValueKey<String>('drawing_1')), findsNothing);
    });

    testWidgets(
        're-subscribes and re-syncs when the repository instance changes',
        (WidgetTester tester) async {
      final AddOnsRepository<DrawingToolConfig> repoA = createRepo()
        ..add(horizontalConfig('repo_a_drawing'));
      final AddOnsRepository<DrawingToolConfig> repoB = createRepo()
        ..add(horizontalConfig('repo_b_drawing'));

      final InteractiveLayerBehaviour behaviour =
          InteractiveLayerDesktopBehaviour();

      await tester.pumpWidget(buildLayer(repo: repoA, behaviour: behaviour));
      await tester.pump();
      expect(
        find.byKey(const ValueKey<String>('repo_a_drawing')),
        findsOneWidget,
      );

      // Swap the repository instance without remounting the layer.
      await tester.pumpWidget(buildLayer(repo: repoB, behaviour: behaviour));
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('repo_b_drawing')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('repo_a_drawing')),
        findsNothing,
      );

      // Mutations on the new repo instance must reach the layer.
      repoB.removeAt(0);
      await tester.pump();
      expect(
        find.byKey(const ValueKey<String>('repo_b_drawing')),
        findsNothing,
      );
    });

    testWidgets(
        'reuses the selected drawing instance when rebuilding after a remount',
        (WidgetTester tester) async {
      final AddOnsRepository<DrawingToolConfig> repo = createRepo()
        ..add(horizontalConfig('selected_drawing'));

      final InteractiveLayerBehaviour behaviour =
          InteractiveLayerDesktopBehaviour();

      await tester.pumpWidget(buildLayer(repo: repo, behaviour: behaviour));
      await tester.pump();

      // Simulate a user selection: the state machine holds the drawing
      // instance that gestures mutate.
      final InteractableDrawing<DrawingToolConfig> selectedInstance =
          behaviour.interactiveLayer.drawings.single;
      behaviour.controller.currentState = InteractiveSelectedToolState(
        selected: selectedInstance,
        interactiveLayerBehaviour: behaviour,
      );

      // Force a full remount of the layer (what happens on symbol/marker
      // changes in MainChart) while behaviour and repo survive.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(buildLayer(repo: repo, behaviour: behaviour));
      await tester.pump();

      // Selection must survive and the rebuilt map must reference the very
      // same instance the state machine mutates on drag.
      expect(
        behaviour.currentState,
        isA<InteractiveSelectedToolState>(),
      );
      expect(
        identical(
          behaviour.interactiveLayer.drawings.single,
          selectedInstance,
        ),
        isTrue,
      );

      // Deleting the tool while it is selected must reset the state machine
      // (the reset happens after the state-change animation completes).
      repo.removeAt(0);
      await tester.pumpAndSettle();
      expect(behaviour.currentState, isA<InteractiveNormalState>());
      expect(
        find.byKey(const ValueKey<String>('selected_drawing')),
        findsNothing,
      );
    });

    testWidgets(
        'state transition completes even when a remount cancels its animation',
        (WidgetTester tester) async {
      final AddOnsRepository<DrawingToolConfig> repo = createRepo()
        ..add(horizontalConfig('drawing_1'));

      final InteractiveLayerBehaviour behaviour =
          InteractiveLayerDesktopBehaviour();

      await tester.pumpWidget(buildLayer(repo: repo, behaviour: behaviour));
      await tester.pump();

      final InteractableDrawing<DrawingToolConfig> drawing =
          behaviour.interactiveLayer.drawings.single;

      // Start a transition that waits for its 240ms animation. A plain
      // TickerFuture would never complete once the layer (and its
      // AnimationController) is disposed mid-animation, silently dropping the
      // state assignment — the release-mode "stuck state machine" bug.
      final Future<void> transition = behaviour.updateStateTo(
        InteractiveSelectedToolState(
          selected: drawing,
          interactiveLayerBehaviour: behaviour,
        ),
        StateChangeAnimationDirection.forward,
      );

      // Animation in flight.
      await tester.pump(const Duration(milliseconds: 50));

      // Keyed remount (symbol/marker change) disposes the gesture handler and
      // its AnimationController while the transition is still awaiting.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(buildLayer(repo: repo, behaviour: behaviour));
      await tester.pump();

      // Must complete (would hang/time out before the fix) and must have
      // applied the state.
      await transition;
      expect(behaviour.currentState, isA<InteractiveSelectedToolState>());
    });

    testWidgets(
        'map adopts the selected instance when it differs for the same id',
        (WidgetTester tester) async {
      final AddOnsRepository<DrawingToolConfig> repo = createRepo();

      final InteractiveLayerBehaviour behaviour =
          InteractiveLayerDesktopBehaviour();

      await tester.pumpWidget(buildLayer(repo: repo, behaviour: behaviour));
      await tester.pump();

      // Add flow ordering: the repo listener creates a map instance for the
      // new config BEFORE the adding flow selects its own (preview) instance
      // for the same configId.
      repo.add(horizontalConfig('added_drawing'));
      await tester.pump();

      final InteractableDrawing<DrawingToolConfig> mapInstance =
          behaviour.interactiveLayer.drawings.single;

      // A different instance built from the same config gets selected (what
      // the adding flow does with the preview's drawing).
      final InteractableDrawing<DrawingToolConfig> selectedInstance =
          horizontalConfig('added_drawing').getInteractableDrawing(
        behaviour.interactiveLayer.drawingContext,
        behaviour.getToolState,
      );
      expect(identical(mapInstance, selectedInstance), isFalse);

      behaviour.controller.currentState = InteractiveSelectedToolState(
        selected: selectedInstance,
        interactiveLayerBehaviour: behaviour,
      );

      // Any rebuild must unify them: the painted/hit-tested instance has to
      // be the one gestures mutate.
      repo.update();
      await tester.pump();

      expect(
        identical(
          behaviour.interactiveLayer.drawings.single,
          selectedInstance,
        ),
        isTrue,
      );
    });

    testWidgets(
        'clear() empties paint/hit-test data even before a rebuild arrives',
        (WidgetTester tester) async {
      final AddOnsRepository<DrawingToolConfig> repo = createRepo()
        ..add(horizontalConfig('drawing_1'))
        ..add(horizontalConfig('drawing_2'))
        ..add(horizontalConfig('drawing_3'));

      final InteractiveLayerBehaviour behaviour =
          InteractiveLayerDesktopBehaviour();

      await tester.pumpWidget(buildLayer(repo: repo, behaviour: behaviour));
      await tester.pump();
      expect(behaviour.interactiveLayer.drawings.length, 3);

      // "Clear all" from the bottom sheet. In release builds the widget
      // rebuild carrying the new (empty) snapshot was observed not to reach
      // the gesture handler, leaving ghost lines painted and hit-testable.
      // The handler must therefore read the reconciled drawings live: they
      // have to be empty immediately after clear(), before any pump delivers
      // a rebuilt widget.
      repo.clear();
      expect(behaviour.interactiveLayer.drawings, isEmpty);

      await tester.pump();
      expect(find.byKey(const ValueKey<String>('drawing_1')), findsNothing);
      expect(find.byKey(const ValueKey<String>('drawing_2')), findsNothing);
      expect(find.byKey(const ValueKey<String>('drawing_3')), findsNothing);
    });

    testWidgets('a superseded transition does not overwrite a newer state',
        (WidgetTester tester) async {
      final AddOnsRepository<DrawingToolConfig> repo = createRepo()
        ..add(horizontalConfig('drawing_1'));

      final InteractiveLayerBehaviour behaviour =
          InteractiveLayerDesktopBehaviour();

      await tester.pumpWidget(buildLayer(repo: repo, behaviour: behaviour));
      await tester.pump();

      final InteractableDrawing<DrawingToolConfig> drawing =
          behaviour.interactiveLayer.drawings.single;

      // Slow transition: suspends on its animation.
      final Future<void> slowTransition = behaviour.updateStateTo(
        InteractiveSelectedToolState(
          selected: drawing,
          interactiveLayerBehaviour: behaviour,
        ),
        StateChangeAnimationDirection.forward,
      );

      // Newer transition applies immediately, cancelling the slow one's
      // animation. When the slow transition resumes it must detect it has
      // been superseded and not roll the state back.
      await behaviour.updateStateTo(
        InteractiveNormalState(interactiveLayerBehaviour: behaviour),
        StateChangeAnimationDirection.forward,
        waitForAnimation: false,
        animate: false,
      );

      await tester.pumpAndSettle();
      await slowTransition;

      expect(behaviour.currentState, isA<InteractiveNormalState>());
    });
  });
}
