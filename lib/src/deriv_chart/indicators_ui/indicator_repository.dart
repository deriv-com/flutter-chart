import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'indicator_config.dart';

/// Storage key of saved indicators.
const String indicatorsKey = 'indicators';

/// Holds indicators that were added to the Chart during runtime.
class IndicatorsRepository {
  /// Initializes
  IndicatorsRepository() : _indicators = <IndicatorConfig>[];

  final List<IndicatorConfig> _indicators;
  SharedPreferences _prefs;

  /// List of indicators.
  List<IndicatorConfig> get indicators => _indicators;

  /// Loads user selected indicators from shared preferences.
  void loadFromPrefs(SharedPreferences prefs) {
    _prefs = prefs;

    if (prefs.containsKey(indicatorsKey)) {
      final List<String> strings = prefs.getStringList(indicatorsKey);
      _indicators.clear();

      for (final String string in strings) {
        final IndicatorConfig indicatorConfig =
            IndicatorConfig.fromJson(jsonDecode(string));
        _indicators.add(indicatorConfig);
      }
    }
  }

  /// Adds new indicator and updates storage.
  Future<void> add(IndicatorConfig indicatorConfig) async {
    _indicators.add(indicatorConfig);
    await _writeToPrefs();
  }

  /// Updates indicator at index and updates storage.
  Future<void> updateAt(int index, IndicatorConfig indicatorConfig) async {
    if (index < 0 || index >= _indicators.length) {
      return;
    }
    _indicators[index] = indicatorConfig;
    await _writeToPrefs();
  }

  /// Removes indicator at index from repository and updates storage.
  Future<void> removeAt(int index) async {
    if (index < 0 || index >= _indicators.length) {
      return;
    }
    _indicators.removeAt(index);
    await _writeToPrefs();
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
