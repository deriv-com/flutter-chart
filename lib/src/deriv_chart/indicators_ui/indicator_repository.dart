// @dart=2.9

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'indicator_config.dart';

/// Storage key of saved indicators.
const String indicatorsKey = 'indicators';

/// Holds indicators that were added to the Chart during runtime.
class IndicatorsRepository extends ChangeNotifier {
  /// Initializes
  IndicatorsRepository() : _indicators = <IndicatorConfig>[];

  final List<IndicatorConfig> _indicators;
  SharedPreferences _prefs;

  /// List of indicators.
  List<IndicatorConfig> get indicators => _indicators;

  /// Loads user selected indicators from shared preferences.
  void loadFromPrefs(SharedPreferences prefs) {
    _prefs = prefs;

    if (!prefs.containsKey(indicatorsKey)) {
      // No saved indicators.
      return;
    }

    final List<String> strings = prefs.getStringList(indicatorsKey);
    _indicators.clear();

    for (final String string in strings) {
      final IndicatorConfig indicatorConfig =
          IndicatorConfig.fromJson(jsonDecode(string));
      _indicators.add(indicatorConfig);
    }
    notifyListeners();
  }

  /// Adds a new indicator and updates storage.
  void add(IndicatorConfig indicatorConfig) {
    _indicators.add(indicatorConfig);
    _writeToPrefs();
    notifyListeners();
  }

  /// Updates indicator at [index] and updates storage.
  void updateAt(int index, IndicatorConfig indicatorConfig) {
    if (index < 0 || index >= _indicators.length) {
      return;
    }
    _indicators[index] = indicatorConfig;
    _writeToPrefs();
    notifyListeners();
  }

  /// Removes indicator at [index] from repository and updates storage.
  void removeAt(int index) {
    if (index < 0 || index >= _indicators.length) {
      return;
    }
    _indicators.removeAt(index);
    _writeToPrefs();
    notifyListeners();
  }

  Future<void> _writeToPrefs() async {
    if (_prefs != null) {
      await _prefs.setStringList(
        indicatorsKey,
        _indicators
            .map((IndicatorConfig config) => jsonEncode(config))
            .toList(),
      );
    }
  }
}
