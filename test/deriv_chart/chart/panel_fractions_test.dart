import 'package:deriv_chart/src/deriv_chart/chart/chart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resizeCascadingFractions', () {
    // Matches Dimens.minChartPanelHeightFraction.
    const double minFraction = 0.1;

    test('shrinks the immediate neighbor when it has room', () {
      final Map<String, double> fractions = <String, double>{
        'a': 0.4,
        'b': 0.3,
        'c': 0.3,
      };

      final bool changed = resizeCascadingFractions(
        fractions,
        <String>['a', 'b', 'c'],
        1, // divider between b and c
        -0.1, // grow c, shrink b
      );

      expect(changed, isTrue);
      expect(fractions['a'], 0.4);
      expect(fractions['b'], closeTo(0.2, 1e-9));
      expect(fractions['c'], closeTo(0.4, 1e-9));
    });

    test(
        'cascades past a middle panel already at minimum height to a '
        'further panel with room', () {
      final Map<String, double> fractions = <String, double>{
        'a': 0.7, // has plenty of room
        'b': minFraction, // already at the minimum
        'c': 0.2,
      };

      final bool changed = resizeCascadingFractions(
        fractions,
        <String>['a', 'b', 'c'],
        1, // divider between b and c
        -0.1, // try to grow c by 0.1, at b's expense
      );

      expect(changed, isTrue);
      // b can't give anything up (already at the minimum), so the shrink
      // cascades to a instead; b is unchanged, c gets the full delta.
      expect(fractions['a'], closeTo(0.6, 1e-9));
      expect(fractions['b'], closeTo(minFraction, 1e-9));
      expect(fractions['c'], closeTo(0.3, 1e-9));
    });

    test('clamps to the total room available across the whole donor chain', () {
      final Map<String, double> fractions = <String, double>{
        'a': 0.15, // only 0.05 of room above the minimum
        'b': minFraction, // already at the minimum
        'c': 0.75,
      };

      final bool changed = resizeCascadingFractions(
        fractions,
        <String>['a', 'b', 'c'],
        1, // divider between b and c
        -0.2, // ask for more than is available
      );

      expect(changed, isTrue);
      expect(fractions['a'], closeTo(minFraction, 1e-9));
      expect(fractions['b'], closeTo(minFraction, 1e-9));
      expect(fractions['c'], closeTo(0.8, 1e-9));
    });

    test('growing the panel above the divider cascades downward instead', () {
      final Map<String, double> fractions = <String, double>{
        'a': 0.2,
        'b': minFraction, // already at the minimum
        'c': 0.7,
      };

      final bool changed = resizeCascadingFractions(
        fractions,
        <String>['a', 'b', 'c'],
        0, // divider between a and b
        0.1, // grow a, shrink b (then cascade to c)
      );

      expect(changed, isTrue);
      expect(fractions['a'], closeTo(0.3, 1e-9));
      expect(fractions['b'], closeTo(minFraction, 1e-9));
      expect(fractions['c'], closeTo(0.6, 1e-9));
    });

    test('returns false and makes no changes when nothing can be donated', () {
      final Map<String, double> fractions = <String, double>{
        'a': minFraction, // at the minimum - nothing to donate
        'b': minFraction, // at the minimum - nothing to donate
        'c': 1 - 2 * minFraction,
      };
      final Map<String, double> before = Map<String, double>.from(fractions);

      final bool changed = resizeCascadingFractions(
        fractions,
        <String>['a', 'b', 'c'],
        1,
        -0.05,
      );

      expect(changed, isFalse);
      expect(fractions, before);
    });
  });

  group('syncPanelFractions', () {
    test('seeds new keys from defaultFraction when nothing is saved yet', () {
      final Map<String, double> fractions = <String, double>{};

      syncPanelFractions(
        fractions,
        <String>['main', 'a'],
        const <String, double>{}, // saved repo hasn't loaded yet
        (String key) => key == 'main' ? 0.7 : 0.3,
      );

      expect(fractions['main'], 0.7);
      expect(fractions['a'], 0.3);
    });

    test(
        'without forceApplySaved, an already-seeded key is never overwritten '
        'by a saved value that arrives later', () {
      final Map<String, double> fractions = <String, double>{
        'main': 0.7,
        'a': 0.3,
      };

      // Simulates the saved fractions finishing their async load only
      // after this chart's first build already seeded the defaults above.
      syncPanelFractions(
        fractions,
        <String>['main', 'a'],
        const <String, double>{'main': 0.4, 'a': 0.6},
        (String key) => key == 'main' ? 0.7 : 0.3,
      );

      expect(fractions['main'], 0.7);
      expect(fractions['a'], 0.3);
    });

    test(
        'forceApplySaved overwrites already-seeded keys with the saved '
        'value - the fix for the load-finishes-after-first-build race', () {
      final Map<String, double> fractions = <String, double>{
        'main': 0.7,
        'a': 0.3,
      };

      syncPanelFractions(
        fractions,
        <String>['main', 'a'],
        const <String, double>{'main': 0.4, 'a': 0.6},
        (String key) => key == 'main' ? 0.7 : 0.3,
        forceApplySaved: true,
      );

      expect(fractions['main'], 0.4);
      expect(fractions['a'], 0.6);
    });

    test(
        'forceApplySaved leaves a key alone if the saved map has no entry '
        'for it (e.g. a newly-added panel not yet in storage)', () {
      final Map<String, double> fractions = <String, double>{'main': 0.5};

      syncPanelFractions(
        fractions,
        <String>['main', 'a'],
        const <String, double>{'main': 0.9}, // no entry for 'a'
        (String key) => key == 'main' ? 0.7 : 0.3,
        forceApplySaved: true,
      );

      // main:a lands at 0.9:0.3 (a fell back to defaultFraction) before
      // being renormalized to sum to 1.0, i.e. a 3:1 ratio.
      expect(fractions['main'], closeTo(0.75, 1e-9));
      expect(fractions['a'], closeTo(0.25, 1e-9));
    });
  });
}
