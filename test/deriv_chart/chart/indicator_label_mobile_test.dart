import 'package:deriv_chart/src/deriv_chart/chart/bottom_chart_mobile.dart';
import 'package:deriv_chart/src/deriv_chart/chart/indicator_label_icons.dart';
import 'package:deriv_chart/src/theme/chart_default_light_theme.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        home: Provider<ChartTheme>.value(
          value: ChartDefaultLightTheme(),
          child:
              Scaffold(body: Align(alignment: Alignment.topLeft, child: child)),
        ),
      );

  group('IndicatorLabelMobile', () {
    testWidgets('collapsed shows only the title and a chevron, no actions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          const IndicatorLabelMobile(
            title: 'RSI (14, C, Y)',
            isExpanded: false,
            showMoveUpIcon: false,
            showMoveDownIcon: false,
            isHidden: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('RSI (14, C, Y)'), findsOneWidget);
      // Chevron is always present.
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      // No action buttons while collapsed.
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);
      expect(find.byIcon(Icons.settings), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('expanded reveals eye, settings and delete actions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          IndicatorLabelMobile(
            title: 'MA (50, C, MA, 0)',
            isExpanded: true,
            showMoveUpIcon: false,
            showMoveDownIcon: false,
            isHidden: false,
            onHideUnhideToggle: () {},
            onEdit: () {},
            onRemove: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('reorder arrows only show when enabled and expanded',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          IndicatorLabelMobile(
            title: 'MACD (12, 26, 9)',
            isExpanded: true,
            showMoveUpIcon: true,
            showMoveDownIcon: true,
            isHidden: false,
            onSwap: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('eye icon reflects the hidden state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          IndicatorLabelMobile(
            title: 'RSI',
            isExpanded: true,
            showMoveUpIcon: false,
            showMoveDownIcon: false,
            isHidden: true,
            onHideUnhideToggle: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);
    });

    testWidgets('tapping the chevron fires onExpandToggle',
        (WidgetTester tester) async {
      int toggles = 0;
      await tester.pumpWidget(
        wrap(
          IndicatorLabelMobile(
            title: 'RSI',
            isExpanded: false,
            showMoveUpIcon: false,
            showMoveDownIcon: false,
            isHidden: false,
            onExpandToggle: () => toggles++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chevron_right));
      expect(toggles, 1);
    });

    testWidgets('tapping the title also fires onExpandToggle',
        (WidgetTester tester) async {
      int toggles = 0;
      await tester.pumpWidget(
        wrap(
          IndicatorLabelMobile(
            title: 'RSI',
            isExpanded: false,
            showMoveUpIcon: false,
            showMoveDownIcon: false,
            isHidden: false,
            onExpandToggle: () => toggles++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('RSI'));
      expect(toggles, 1);
    });

    testWidgets('custom icons override the Material defaults',
        (WidgetTester tester) async {
      const IndicatorLabelIcons customIcons = IndicatorLabelIcons(
        show: Icons.remove_red_eye,
        hide: Icons.hide_source,
        settings: Icons.tune,
        delete: Icons.close,
        expandCollapse: Icons.arrow_forward_ios,
      );

      await tester.pumpWidget(
        wrap(
          IndicatorLabelMobile(
            title: 'MA',
            isExpanded: true,
            showMoveUpIcon: false,
            showMoveDownIcon: false,
            isHidden: false,
            icons: customIcons,
            onHideUnhideToggle: () {},
            onEdit: () {},
            onRemove: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Custom icons are used.
      expect(find.byIcon(Icons.remove_red_eye), findsOneWidget);
      expect(find.byIcon(Icons.tune), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
      // Material defaults are no longer present.
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);
      expect(find.byIcon(Icons.settings), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('custom hidden icon is used when hidden',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          IndicatorLabelMobile(
            title: 'MA',
            isExpanded: true,
            showMoveUpIcon: false,
            showMoveDownIcon: false,
            isHidden: true,
            icons: const IndicatorLabelIcons(hide: Icons.hide_source),
            onHideUnhideToggle: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.hide_source), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
    });

    testWidgets('action buttons invoke their callbacks',
        (WidgetTester tester) async {
      int hide = 0;
      int edit = 0;
      int remove = 0;
      await tester.pumpWidget(
        wrap(
          IndicatorLabelMobile(
            title: 'MA',
            isExpanded: true,
            showMoveUpIcon: false,
            showMoveDownIcon: false,
            isHidden: false,
            onHideUnhideToggle: () => hide++,
            onEdit: () => edit++,
            onRemove: () => remove++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.tap(find.byIcon(Icons.settings));
      await tester.tap(find.byIcon(Icons.delete_outline));

      expect(hide, 1);
      expect(edit, 1);
      expect(remove, 1);
    });
  });
}
