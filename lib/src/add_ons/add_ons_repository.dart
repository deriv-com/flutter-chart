import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage key of saved indicators.
const String addOnsKey = 'addOns';

/// Called when an addOn is to be removed
///
/// [id] is the id of the addOn to be removed
typedef OnRemoveCallback = void Function(String id);

/// Called when an addOn is to be edited
///
/// [id] is the id of the addOn to be edited
typedef OnEditCallback = void Function(String id);

/// Holds indicators/drawing tools that were added to the Chart during runtime.
class AddOnsRepository<T> extends ChangeNotifier {
  /// Initializes
  AddOnsRepository(
    this._addOnConfig, {
    this.onRemoveAddOn,
    this.onEditAddOn,
  }) : _addOns = <T>[];

  final dynamic _addOnConfig;

  final List<T> _addOns;
  SharedPreferences? _prefs;

  /// List of indicators or drawing tools.
  List<T> get addOns => _addOns;

  /// Called when an addOn is to be removed.
  OnRemoveCallback? onRemoveAddOn;

  /// Called when an addOn is to be edited.
  OnEditCallback? onEditAddOn;

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
    notifyListeners();
  }

  /// Adds a new indicator or drawing tool and updates storage.
  void add(T addOnConfig) {
    _addOns.add(addOnConfig);
    _writeToPrefs();
    notifyListeners();
  }

  /// Updates indicator or drawing tool at [index] and updates storage.
  void updateAt(int index, T addOnConfig) {
    if (index < 0 || index >= _addOns.length) {
      return;
    }
    _addOns[index] = addOnConfig;
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
