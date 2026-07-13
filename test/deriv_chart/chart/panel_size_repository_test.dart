import 'dart:convert';

import 'package:deriv_chart/src/deriv_chart/chart/panel_size/panel_size_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const String storageKey = 'panelHeights';

  group('PanelSizeRepository', () {
    test('loadFromPrefs with no saved data leaves fractions empty', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final PanelSizeRepository repo = PanelSizeRepository();
      repo.loadFromPrefs(prefs);

      expect(repo.fractions, isEmpty);
    });

    test('loadFromPrefs restores previously saved fractions', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        storageKey: jsonEncode(<String, double>{
          PanelSizeRepository.mainPanelKey: 0.6,
          'indicator_1': 0.4,
        }),
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final PanelSizeRepository repo = PanelSizeRepository();
      repo.loadFromPrefs(prefs);

      expect(repo.fractions[PanelSizeRepository.mainPanelKey], 0.6);
      expect(repo.fractions['indicator_1'], 0.4);
    });

    test('save persists fractions and updates the in-memory value', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final PanelSizeRepository repo = PanelSizeRepository();
      repo.loadFromPrefs(prefs);

      await repo.save(<String, double>{
        PanelSizeRepository.mainPanelKey: 0.7,
        'indicator_1': 0.3,
      });

      expect(repo.fractions[PanelSizeRepository.mainPanelKey], 0.7);

      // Round-trips through a fresh instance/prefs read.
      final PanelSizeRepository reloaded = PanelSizeRepository();
      reloaded.loadFromPrefs(prefs);

      expect(reloaded.fractions[PanelSizeRepository.mainPanelKey], 0.7);
      expect(reloaded.fractions['indicator_1'], 0.3);
    });

    test(
        'fractions are not scoped per symbol - the same saved sizes apply '
        'regardless of which symbol/market is active', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        storageKey: jsonEncode(<String, double>{'main': 0.6}),
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final PanelSizeRepository repo = PanelSizeRepository();
      repo.loadFromPrefs(prefs);
      expect(repo.fractions['main'], 0.6);

      // Loading again (e.g. simulating a symbol switch) reads the exact
      // same global entry, not a per-symbol one.
      repo.loadFromPrefs(prefs);
      expect(repo.fractions['main'], 0.6);
    });

    test('loadGeneration starts at 0 and bumps on every loadFromPrefs call',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final PanelSizeRepository repo = PanelSizeRepository();
      expect(repo.loadGeneration, 0);

      repo.loadFromPrefs(prefs);
      expect(repo.loadGeneration, 1);

      // A later reload bumps it again, so a `Chart` that already applied
      // generation 1 knows to re-apply.
      repo.loadFromPrefs(prefs);
      expect(repo.loadGeneration, 2);
    });
  });
}
