import 'dart:convert';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage key of saved indicators/drawing tools.
const String addOnsKey = 'addOns';

/// Holds indicators/drawing tools that were added to the Chart during runtime.
class AddOnsRepository<AddOnConfig> extends ChangeNotifier {
  /// Initializes
  AddOnsRepository(this._addOnConfig) : _addOns = <AddOnConfig>[];

  final dynamic _addOnConfig;

  /// List containing addOns
  final List<AddOnConfig> _addOns;
  SharedPreferences? _prefs;

  /// List of indicators.
  List<AddOnConfig> get addOns => getAddOns();

  /// Getter for the list of addOns indicators or drawing tools.
  List<AddOnConfig> getAddOns() => _addOns;

  /// Loads user selected indicators or drawing tools from shared preferences.
  void loadFromPrefs(SharedPreferences prefs) {
    _prefs = prefs;

    if (!prefs.containsKey(addOnsKey)) {
      // No saved indicators or drawing tools.
      return;
    }

    final List<String> encodedAddOns = prefs.getStringList(addOnsKey)!;
    getAddOns().clear();

    for (final String encodedAddOn in encodedAddOns) {
      dynamic addOnConfig;
      if (_addOnConfig is IndicatorConfig) {
        addOnConfig =
            IndicatorConfig.fromJson(jsonDecode(encodedAddOn)) as AddOnConfig;
      } else if (_addOnConfig is DrawingToolConfig) {
        addOnConfig =
            DrawingToolConfig.fromJson(jsonDecode(encodedAddOn)) as AddOnConfig;
      }
      if (addOnConfig == null) {
        continue;
      } else {
        getAddOns().add(addOnConfig);
      }
    }
    notifyListeners();
  }

  /// Adds a new indicator or drawing tool and updates storage.
  void add(AddOnConfig addOnConfig) {
    getAddOns().add(addOnConfig);
    _writeToPrefs();
    notifyListeners();
  }

  /// Updates indicator or drawing tool at [index] and updates storage.
  void updateAt(int index, AddOnConfig addOnConfig) {
    if (index < 0 || index >= getAddOns().length) {
      return;
    }
    getAddOns()[index] = addOnConfig;
    _writeToPrefs();
    notifyListeners();
  }

  /// Removes indicator/drawing tool at [index] from repository and
  /// updates storage.
  void removeAt(int index) {
    if (index < 0 || index >= getAddOns().length) {
      return;
    }
    getAddOns().removeAt(index);
    notifyListeners();
  }

  Future<void> _writeToPrefs() async {
    if (_prefs != null) {
      await _prefs!.setStringList(
        addOnsKey,
        getAddOns().map((AddOnConfig config) => jsonEncode(config)).toList(),
      );
    }
  }
}
