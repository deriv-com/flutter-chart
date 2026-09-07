import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/drawing_context.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/interactive_layer_base.dart';
import 'package:deriv_chart/src/deriv_chart/interactive_layer/widgets/selected_drawing_floating_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// The floating menu only reaches into the layer to hide the crosshair while
/// it is being dragged; nothing else on [InteractiveLayerBase] is exercised.
class _FakeInteractiveLayer extends Fake implements InteractiveLayerBase {
  @override
  void hideCrosshair() {}
}

void main() {
  const Key parentKey = Key('floating_menu_parent');

  late AnimationController stateChangeController;
  late InteractiveLayerBehaviour behaviour;

  setUp(() {
    // value: 1 => the menu is fully shown (no scale / fade in progress).
    stateChangeController = AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 100),
      value: 1,
    );
    behaviour = InteractiveLayerDesktopBehaviour()
      ..stateChangeController = stateChangeController
      ..interactiveLayer = _FakeInteractiveLayer();
  });

  tearDown(() {
    stateChangeController.dispose();
  });

  InteractableDrawing<DrawingToolConfig> createDrawing() =>
      HorizontalDrawingToolConfig(
        configId: 'floating_menu_test',
        edgePoints: const <EdgePoint>[EdgePoint(epoch: 2000, quote: 20)],
      ).getInteractableDrawing(
        DrawingContext(
          fullSize: const Size(800, 600),
          contentSize: const Size(740, 600),
        ),
        behaviour.getToolState,
      );

  /// Mounts the menu inside a [Stack] of exactly [parentSize], the way the
  /// interactive layer hosts it.
  Widget buildMenu({required Size parentSize}) => MaterialApp(
        home: Provider<ChartTheme>.value(
          value: ChartDefaultDarkTheme(),
          child: Material(
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox.fromSize(
                size: parentSize,
                child: Stack(
                  key: parentKey,
                  children: <Widget>[
                    SelectedDrawingFloatingMenu(
                      drawing: createDrawing(),
                      interactiveLayerBehaviour: behaviour,
                      onUpdateDrawing: (_) {},
                      onRemoveDrawing: (_) {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Finder menuFinder() => find.byType(SelectedDrawingFloatingMenu);

  /// The menu's top-left corner relative to its parent [Stack].
  Offset menuOffset(WidgetTester tester) =>
      tester.getTopLeft(menuFinder()) -
      tester.getTopLeft(find.byKey(parentKey));

  /// Starts a pan on the drag handle (the leading 32x32 area of the menu) from
  /// a point that is inside the parent even when the parent is tiny.
  Future<void> dragMenu(WidgetTester tester, Offset delta) async {
    final Offset start =
        tester.getTopLeft(find.byKey(parentKey)) + const Offset(8, 8);
    await tester.dragFrom(start, delta);
    await tester.pump();
  }

  group('SelectedDrawingFloatingMenu drag clamping', () {
    testWidgets(
        'does not throw and pins to the origin when the parent is smaller '
        'than the menu on both axes', (WidgetTester tester) async {
      const Size parentSize = Size(100, 20);

      await tester.pumpWidget(buildMenu(parentSize: parentSize));
      // Lets the post-frame callback measure the menu.
      await tester.pump();

      final Size menuSize = tester.getSize(menuFinder());
      expect(menuSize.width, greaterThan(parentSize.width),
          reason: 'precondition: parent must be narrower than the menu');
      expect(menuSize.height, greaterThan(parentSize.height),
          reason: 'precondition: parent must be shorter than the menu');

      await dragMenu(tester, const Offset(40, 30));

      // Before the fix `clamp(0.0, negativeUpperBound)` threw
      // `ArgumentError: Invalid argument(s): 0.0` from onPanUpdate.
      expect(tester.takeException(), isNull);
      expect(menuOffset(tester), Offset.zero);
      expect(behaviour.controller.floatingMenuPosition, Offset.zero);
    });

    testWidgets('clamps each axis independently when only one axis overflows',
        (WidgetTester tester) async {
      const Size parentSize = Size(400, 20);

      await tester.pumpWidget(buildMenu(parentSize: parentSize));
      await tester.pump();

      final Size menuSize = tester.getSize(menuFinder());
      expect(menuSize.width, lessThan(parentSize.width));
      expect(menuSize.height, greaterThan(parentSize.height));

      await dragMenu(tester, const Offset(50, 50));

      expect(tester.takeException(), isNull);
      final Offset offset = menuOffset(tester);
      // The axis that fits still moves within [0, parent - menu] ...
      expect(offset.dx, greaterThan(0));
      expect(offset.dx, lessThanOrEqualTo(parentSize.width - menuSize.width));
      // ... while the axis that does not fit stays pinned at 0.
      expect(offset.dy, 0);
    });

    testWidgets('keeps clamping to the parent bounds when the menu fits',
        (WidgetTester tester) async {
      const Size parentSize = Size(400, 200);

      await tester.pumpWidget(buildMenu(parentSize: parentSize));
      await tester.pump();

      final Size menuSize = tester.getSize(menuFinder());
      expect(menuSize.width, lessThan(parentSize.width));
      expect(menuSize.height, lessThan(parentSize.height));

      // Drag far past the bottom-right corner.
      await dragMenu(tester, const Offset(1000, 1000));

      expect(tester.takeException(), isNull);
      final Offset expected = Offset(
        parentSize.width - menuSize.width,
        parentSize.height - menuSize.height,
      );
      expect(menuOffset(tester), expected);
      expect(behaviour.controller.floatingMenuPosition, expected);
    });
  });
}
