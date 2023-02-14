import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deriv_chart/src/add_ons/add_on_config.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';

/// Storage key of saved indicators.
const String addOnsKey = 'addOns';

/// Holds indicators/drawing tools that were added to the Chart during runtime.
class AddOnsRepository<T extends AddOnConfig> extends ChangeNotifier
    implements Repository<T> {
  /// Initializes
  AddOnsRepository(this._addOnConfig, {this.onEditCallback}) : _addOns = <T>[];

  final dynamic _addOnConfig;

  final List<T> _addOns;
  SharedPreferences? _prefs;

  /// List of indicators or drawing tools.
  @override
  List<T> get items => _addOns;

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
    _addOns.clear();

    for (final String encodedAddOn in encodedAddOns) {
      final T addOnConfig = _addOnConfig.fromJson(jsonDecode(encodedAddOn));
      _addOns.add(addOnConfig);
    }
  }

  /// Adds a new indicator or drawing tool and updates storage.
  @override
  void add(T addOnConfig) {
    _addOns.add(addOnConfig);
    _writeToPrefs();
    notifyListeners();
  }

  /// Called when the edit icon is clicked.
  @override
  void editAt(
    int index,
  ) {
    onEditCallback?.call();
  }

  /// Updates indicator or drawing tool at [index] and updates storage.
  @override
  void updateAt(int index, T addOnConfig) {
    if (index < 0 || index >= _addOns.length) {
      return;
    }
    _addOns[index] = addOnConfig;
    _writeToPrefs();
    notifyListeners();
  }

  /// Removes indicator/drawing tool at [index] from repository and updates storage.
  @override
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
