import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the relative heights (as fractions of the total available
/// height) of the chart's vertically stacked panels: [MainChart] and each
/// bottom indicator panel.
///
/// Panels are identified by a string key: `'main'` for the main chart, and
/// `IndicatorConfig.configId` for each bottom indicator panel.
class PanelSizeRepository extends ChangeNotifier {
  /// Key of the [MainChart] panel in [fractions].
  static const String mainPanelKey = 'main';

  String _sharedPrefKey = '';

  /// Current known fractions, keyed by panel key.
  ///
  /// Empty until [loadFromPrefs] has completed, or until [save] has been
  /// called at least once.
  Map<String, double> fractions = <String, double>{};

  SharedPreferences? _prefs;

  /// Storage key of the saved panel fractions.
  String get _storageKey => 'panelHeights_$_sharedPrefKey';

  /// Loads previously saved panel fractions for [symbol] from [prefs].
  void loadFromPrefs(SharedPreferences prefs, String symbol) {
    _prefs = prefs;
    _sharedPrefKey = symbol;

    final String? encoded = prefs.getString(_storageKey);

    if (encoded == null) {
      fractions = <String, double>{};
      notifyListeners();
      return;
    }

    final Map<String, dynamic> decoded =
        jsonDecode(encoded) as Map<String, dynamic>;

    fractions = decoded.map(
      (String key, dynamic value) => MapEntry<String, double>(
        key,
        (value as num).toDouble(),
      ),
    );

    notifyListeners();
  }

  /// Saves [newFractions] for the current symbol and updates [fractions].
  Future<void> save(Map<String, double> newFractions) async {
    fractions = Map<String, double>.from(newFractions);

    if (_prefs != null) {
      await _prefs!.setString(_storageKey, jsonEncode(fractions));
    }

    notifyListeners();
  }
}
