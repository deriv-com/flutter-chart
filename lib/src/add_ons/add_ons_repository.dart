import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage key of saved indicators.
const String addOnsKey = 'addOns';

/// Holds indicators/drawing tools that were added to the Chart during runtime.
class AddOnsRepository<T> extends ChangeNotifier {
  /// Initializes
  AddOnsRepository(this._addOnsConfig) : _addOns = <T>[];

  final dynamic _addOnsConfig;

  final List<T> _addOns;
  SharedPreferences? _prefs;

  /// List of indicators or drawing tools.
  List<T> get addOns => _addOns;

  /// Loads user selected indicators or drawing tools from shared preferences.
  void loadFromPrefs(SharedPreferences prefs) {
    _prefs = prefs;

    if (!prefs.containsKey(addOnsKey)) {
      // No saved indicators or drawing tools.
      return;
    }

    final List<String> strings = prefs.getStringList(addOnsKey)!;
    _addOns.clear();

    for (final String string in strings) {
      final T addOnsConfig = _addOnsConfig.fromJson(jsonDecode(string));
      _addOns.add(addOnsConfig);
    }
    notifyListeners();
  }

  /// Adds a new indicator or drawing tool and updates storage.
  void add(T addOnsConfig) {
    _addOns.add(addOnsConfig);
    _writeToPrefs();
    notifyListeners();
  }

  /// Updates indicator or drawing tool at [index] and updates storage.
  void updateAt(int index, T addOnsConfig) {
    if (index < 0 || index >= _addOns.length) {
      return;
    }
    _addOns[index] = addOnsConfig;
    _writeToPrefs();
    notifyListeners();
  }

  /// Removes indicator/drawing tool at [index] from repository and updates storage.
  void removeAt(int index) {
    if (index < 0 || index >= _addOns.length) {
      return;
    }
    _addOns.removeAt(index);
    _writeToPrefs();
    notifyListeners();
  }

  Future<void> _writeToPrefs() async {
    if (_prefs != null) {
      await _prefs!.setStringList(
        addOnsKey,
        _addOns.map((T config) => jsonEncode(config)).toList(),
      );
    }
  }
}
