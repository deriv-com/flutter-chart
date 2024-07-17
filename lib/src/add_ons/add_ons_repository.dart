import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/src/add_ons/add_on_config.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_on_config_wrapper.dart';

/// Called to create an AddOnConfig object from a map.
typedef CreateAddOn<T extends AddOnConfig> = AddOnConfigWrapper<T> Function(
  Map<String, dynamic> map,
);

/// Called when the edit icon is clicked on an add-on.
typedef OnEditAddOn = Function(int index);

/// Holds indicators/drawing tools that were added to the Chart during runtime.
class AddOnsRepository<T extends AddOnConfig> extends ChangeNotifier
    implements Repository<T> {
  /// Initializes
  AddOnsRepository({
    required this.createAddOn,
    required this.sharedPrefKey,
    this.onEditCallback,
  }) : _addOns = <AddOnConfigWrapper<T>>[];

  /// Key String acts as a key for the set of indicators that are saved.
  ///
  /// We can have separate set of saved indicators per key.
  String sharedPrefKey;

  /// List containing addOns
  final List<AddOnConfigWrapper<T>> _addOns;
  final Map<String, bool> _hiddenStatus = <String, bool>{};
  SharedPreferences? _prefs;

  /// List of indicators.
  @override
  List<AddOnConfigWrapper<T>> get items => _addOns;

  /// Storage key of saved indicators/drawing tools.
  String get addOnsKey => 'addOns_${T.toString()}_$sharedPrefKey';

  /// Called to create an AddOnConfig object from a map.
  CreateAddOn<T> createAddOn;

  /// Called when the edit icon is clicked.
  OnEditAddOn? onEditCallback;

  /// Loads user selected indicators or drawing tools from shared preferences.
  void loadFromPrefs(SharedPreferences prefs, String symbol) {
    _prefs = prefs;
    sharedPrefKey = symbol;

    items.clear();
    _hiddenStatus.clear();

    if (!prefs.containsKey(addOnsKey)) {
      // No saved indicators or drawing tools.
      return;
    }

    final List<String> encodedAddOns = prefs.getStringList(addOnsKey)!;

    final List<Map<String, dynamic>> decodedAddons = encodedAddOns
        .map<Map<String, dynamic>>(
            (String encodedAddOn) => jsonDecode(encodedAddOn))
        .toList();

    for (final Map<String, dynamic> decodedAddon in decodedAddons) {
      final AddOnConfigWrapper<T> addOnConfig = createAddOn.call(decodedAddon);
      items.add(addOnConfig);
      _hiddenStatus[addOnConfig.id] = false;
    }
  }

  /// Adds a new indicator or drawing tool and updates storage.
  @override
  void add(AddOnConfigWrapper<T> addOnConfig) {
    items.add(addOnConfig);
    _hiddenStatus[addOnConfig.id] = false;
    _writeToPrefs();
    notifyListeners();
  }

  /// Called when the edit icon is clicked.
  @override
  void editAt(int index) {
    onEditCallback?.call(index);
  }

  /// Updates indicator or drawing tool at [index] and updates storage.
  @override
  void updateAt(int index, AddOnConfigWrapper<T> addOnConfig) {
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
  void removeAt(int index) {
    if (index < 0 || index >= items.length) {
      return;
    }
    final AddOnConfigWrapper<T> removedItem = items.removeAt(index);
    _hiddenStatus.removeWhere((String key, _) => key == removedItem.id);
    _writeToPrefs();
    notifyListeners();
  }

  /// Removes all indicator/drawing tool from repository and
  /// updates storage.
  @override
  void clear() {
    items.clear();
    _hiddenStatus.clear();
    _writeToPrefs();
    notifyListeners();
  }

  /// Swaps two elements of a list and updates storage.
  @override
  void swap(int index1, int index2) {
    items.swap(index1, index2);
    _writeToPrefs();
    notifyListeners();
  }

  Future<void> _writeToPrefs() async {
    if (_prefs != null) {
      await _prefs!.setStringList(
        addOnsKey,
        items
            .map((AddOnConfigWrapper<T> config) =>
                jsonEncode(config.addOnConfig.toJson()))
            .toList(),
      );
    }
  }

  /// Updates the hidden status of an indicator or drawing tool.
  @override
  void updateHiddenStatus({
    required AddOnConfigWrapper<T> addOn,
    required bool hidden,
  }) {
    _hiddenStatus[addOn.id] = hidden;
    notifyListeners();
  }

  @override
  bool getHiddenStatus(AddOnConfigWrapper<T> addOn) =>
      _hiddenStatus[addOn.id] ?? false;
}
