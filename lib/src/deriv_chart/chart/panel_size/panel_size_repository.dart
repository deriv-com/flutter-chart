import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the relative heights (as fractions of the total available
/// height) of the chart's vertically stacked panels: [MainChart] and each
/// bottom indicator panel.
///
/// Panels are identified by a string key: `'main'` for the main chart, and
/// `IndicatorConfig.configId` for each bottom indicator panel.
///
/// Deliberately **not** scoped by symbol - unlike indicators or drawing
/// tools, a resized panel layout is a user preference about how they like
/// to view charts in general, not something tied to a particular market, so
/// it stays the same across symbol switches instead of being reloaded (or
/// reset) per symbol.
class PanelSizeRepository extends ChangeNotifier {
  /// Key of the [MainChart] panel in [fractions].
  static const String mainPanelKey = 'main';

  /// Storage key of the saved panel fractions. Not symbol-scoped - see the
  /// class doc.
  static const String _storageKey = 'panelHeights';

  /// Current known fractions, keyed by panel key.
  ///
  /// Empty until [loadFromPrefs] has completed, or until [save] has been
  /// called at least once.
  Map<String, double> fractions = <String, double>{};

  SharedPreferences? _prefs;

  int _loadGeneration = 0;

  /// Bumped every time [loadFromPrefs] completes (0 means it never has).
  ///
  /// `SharedPreferences` access is async, so a chart's very first build
  /// always happens before this repo has finished loading - it seeds panels
  /// with default fractions first, then needs to know when the load has
  /// completed so it can re-apply the real saved fractions over those
  /// defaults. A plain "have we ever loaded" flag isn't enough for that: it
  /// also has to notice a *second* load completing (e.g. if a host app
  /// calls [loadFromPrefs] again later), which is what a bumping generation
  /// counter - rather than a one-shot bool - is for.
  int get loadGeneration => _loadGeneration;

  /// Loads previously saved panel fractions from [prefs].
  void loadFromPrefs(SharedPreferences prefs) {
    _prefs = prefs;

    final String? encoded = prefs.getString(_storageKey);

    if (encoded == null) {
      fractions = <String, double>{};
      _loadGeneration++;
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

    _loadGeneration++;
    notifyListeners();
  }

  /// Saves [newFractions] and updates [fractions].
  Future<void> save(Map<String, double> newFractions) async {
    fractions = Map<String, double>.from(newFractions);

    if (_prefs != null) {
      await _prefs!.setString(_storageKey, jsonEncode(fractions));
    }

    notifyListeners();
  }
}
