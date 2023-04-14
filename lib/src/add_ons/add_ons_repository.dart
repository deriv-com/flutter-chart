import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:deriv_chart/src/add_ons/drawing_tools_ui/drawing_tool_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/add_ons/add_on_config.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds indicators/drawing tools that were added to the Chart during runtime.
class AddOnsRepository<T extends AddOnConfig> extends ChangeNotifier
    implements Repository<T> {
  /// Initializes
  AddOnsRepository({this.onEditCallback}) : _addOns = <T>[];

  /// List containing addOns
  final List<T> _addOns;
  SharedPreferences? _prefs;

  /// List of indicators.
  @override
  List<T> get items => _addOns;

  /// Storage key of saved indicators/drawing tools.
  String get addOnsKey => 'addOns_${T.toString()}';

  /// Called when the edit icon is clicked.
  VoidCallback? onEditCallback;

  /// Loads user selected indicators or drawing tools from shared preferences.
  void loadFromPrefs(SharedPreferences prefs) {
    _prefs = prefs;

    if (!prefs.containsKey(addOnsKey)) {
      // No saved indicators or drawing tools.
      return;
    }

    final List<String> encodedAddOns = prefs.getStringList(addOnsKey)!;
    items.clear();

    for (final String encodedAddOn in encodedAddOns) {
      T? addOnConfig;
      if (T == IndicatorConfig) {
        addOnConfig = IndicatorConfig.fromJson(jsonDecode(encodedAddOn)) as T;
      } else if (T == DrawingToolConfig) {
        addOnConfig = DrawingToolConfig.fromJson(jsonDecode(encodedAddOn)) as T;
      }
      if (addOnConfig == null) {
        continue;
      } else {
        items.add(addOnConfig);
      }
    }
  }

  /// Adds a new indicator or drawing tool and updates storage.
  @override
  void add(T addOnConfig) {
    items.add(addOnConfig);
    _writeToPrefs();
    notifyListeners();
  }

  /// Called when the edit icon is clicked.
  @override
  void edit(
    T config,
  ) {
    onEditCallback?.call();
  }

  /// Updates indicator or drawing tool at [index] and updates storage.
  @override
  void updateAt(int index, T addOnConfig) {
    if (index < 0 || index >= items.length) {
      return;
    }
    items[index] = addOnConfig;
    _writeToPrefs();
    notifyListeners();
  }

  /// Removes indicator/drawing tool at [index] from repository and
  /// updates storage.
  @override
  void remove(T config) {
    if (!items.contains(config)) {
      return;
    }
    items.remove(config);
    notifyListeners();
  }

  Future<void> _writeToPrefs() async {
    if (_prefs != null) {
      await _prefs!.setStringList(
        addOnsKey,
        items.map((AddOnConfig config) => jsonEncode(config)).toList(),
      );
    }
  }
}
