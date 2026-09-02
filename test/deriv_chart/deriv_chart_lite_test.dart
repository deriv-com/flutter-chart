import 'package:deriv_chart/core_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/panel_size/panel_size_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `DerivChartLite` is a thin wrapper that forwards its configuration to
/// [Chart]. Both parameters asserted here were missing from it until recently -
/// consumers on this entry point silently got no persisted panel sizes and no
/// custom indicator-label icons - and neither has any visible effect until the
/// chart renders on web, so a silent drop is easy to reintroduce and hard to
/// notice. These pin the wiring itself.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  final List<Tick> ticks = <Tick>[
    const Tick(epoch: 1000, quote: 10),
    const Tick(epoch: 2000, quote: 20),
  ];

  Widget app({
    PanelSizeRepository? panelSizeRepo,
    IndicatorLabelIcons? indicatorLabelIcons,
  }) =>
      MaterialApp(
        home: Scaffold(
          body: DerivChart(
            mainSeries: LineSeries(ticks),
            granularity: 1000,
            activeSymbol: 'R_100',
            panelSizeRepo: panelSizeRepo,
            indicatorLabelIcons: indicatorLabelIcons,
          ),
        ),
      );

  /// Pumps [widget] and returns the [Chart] it built.
  ///
  /// Laying the chart out makes `BasicChart` drive its quote-bound
  /// `AnimationController` from inside a `LayoutBuilder` callback, which the
  /// test framework flags as "setState() called during build". That is
  /// pre-existing behaviour of the chart itself, unrelated to the wiring under
  /// test, so it is drained rather than left to fail the test.
  Future<Chart> pumpAndFindChart(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(widget);
    while (tester.takeException() != null) {}
    return tester.widget<Chart>(find.byType(Chart));
  }

  testWidgets('forwards a supplied panelSizeRepo to Chart',
      (WidgetTester tester) async {
    final PanelSizeRepository repo = PanelSizeRepository();
    addTearDown(repo.dispose);

    final Chart chart = await pumpAndFindChart(tester, app(panelSizeRepo: repo));

    expect(chart.panelSizeRepo, same(repo));
  });

  testWidgets('falls back to an internally owned panelSizeRepo',
      (WidgetTester tester) async {
    final Chart chart = await pumpAndFindChart(tester, app());

    // Not the host's, but still present - panel sizes persist by default.
    expect(chart.panelSizeRepo, isNotNull);
  });

  testWidgets('forwards indicatorLabelIcons to Chart',
      (WidgetTester tester) async {
    const IndicatorLabelIcons icons = IndicatorLabelIcons(
      show: Icons.star,
      hide: Icons.star_border,
      settings: Icons.tune,
      delete: Icons.clear,
      moveUp: Icons.north,
      moveDown: Icons.south,
      expandCollapse: Icons.expand_more,
    );

    final Chart chart =
        await pumpAndFindChart(tester, app(indicatorLabelIcons: icons));

    expect(chart.indicatorLabelIcons, same(icons));
  });

  testWidgets('leaves indicatorLabelIcons null so Chart applies its defaults',
      (WidgetTester tester) async {
    final Chart chart = await pumpAndFindChart(tester, app());

    expect(chart.indicatorLabelIcons, isNull);
  });
}
