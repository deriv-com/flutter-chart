import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'indicator_config.dart';

const String indicatorsKey = 'indicators';

/// Holds indicators that were added to the Chart during runtime.
class IndicatorsRepository {
  /// Initializes
  IndicatorsRepository() : _indicators = <IndicatorConfig>[];

  final List<IndicatorConfig> _indicators;

  /// List of indicators.
  List<IndicatorConfig> get indicators => _indicators;

  /// Loads user selected indicators from shared preferences.
  void loadFromPrefs(SharedPreferences prefs) {
    if (prefs.containsKey(indicatorsKey)) {
      final List<String> strings = prefs.getStringList(indicatorsKey);

      for (final String string in strings) {
        final IndicatorConfig indicatorConfig =
            IndicatorConfig.fromJson(jsonDecode(string));

        // TODO: Add config to repo
      }
    }
  }
}
