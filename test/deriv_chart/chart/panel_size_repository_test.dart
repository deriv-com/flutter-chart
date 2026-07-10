import 'dart:convert';

import 'package:deriv_chart/src/deriv_chart/chart/panel_size/panel_size_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const String symbol = 'R_100';
  final String storageKey = 'panelHeights_$symbol';

  group('PanelSizeRepository', () {
    test('loadFromPrefs with no saved data leaves fractions empty', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final PanelSizeRepository repo = PanelSizeRepository();
      repo.loadFromPrefs(prefs, symbol);

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
      repo.loadFromPrefs(prefs, symbol);

      expect(repo.fractions[PanelSizeRepository.mainPanelKey], 0.6);
      expect(repo.fractions['indicator_1'], 0.4);
    });

    test('save persists fractions and updates the in-memory value', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final PanelSizeRepository repo = PanelSizeRepository();
      repo.loadFromPrefs(prefs, symbol);

      await repo.save(<String, double>{
        PanelSizeRepository.mainPanelKey: 0.7,
        'indicator_1': 0.3,
      });

      expect(repo.fractions[PanelSizeRepository.mainPanelKey], 0.7);

      // Round-trips through a fresh instance/prefs read.
      final PanelSizeRepository reloaded = PanelSizeRepository();
      reloaded.loadFromPrefs(prefs, symbol);

      expect(reloaded.fractions[PanelSizeRepository.mainPanelKey], 0.7);
      expect(reloaded.fractions['indicator_1'], 0.3);
    });

    test('fractions are scoped per symbol', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'panelHeights_R_100': jsonEncode(<String, double>{'main': 0.6}),
        'panelHeights_R_50': jsonEncode(<String, double>{'main': 0.8}),
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final PanelSizeRepository repo = PanelSizeRepository();
      repo.loadFromPrefs(prefs, 'R_100');
      expect(repo.fractions['main'], 0.6);

      repo.loadFromPrefs(prefs, 'R_50');
      expect(repo.fractions['main'], 0.8);
    });
  });
}
