import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/src/add_ons/add_on_config.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Called to create an AddOnConfig object from a map.
typedef CreateAddOn<T extends AddOnConfig> = T Function(
    Map<String, dynamic> map);

/// Called when the edit icon is clicked on an add-on.
typedef OnEditAddOn = Function(int index);

/// Called when an add-on is deleted from the repository.
typedef OnDeleteAddOn<T extends AddOnConfig> = Function(T item, int index);

/// Swaps two elements of a list.
typedef OnSwapCallback = void Function(int index1, int index2);

/// Holds indicators/drawing tools that were added to the Chart during runtime.
class AddOnsRepository<T extends AddOnConfig> extends ChangeNotifier
    implements Repository<T> {
  /// Initializes
  AddOnsRepository({
    required this.createAddOn,
    required this.sharedPrefKey,
    this.onEditCallback,
    this.onDeleteCallback,
    this.onSwapCallback,
  }) : _addOns = <T>[];

  /// Key String acts as a key for the set of indicators that are saved.
  ///
  /// We can have separate set of saved indicators per key.
  String sharedPrefKey;

  /// List containing addOns
  final List<T> _addOns;

  // TODO(Ramin): once we handle setting [AddOnConfig.number] inside this class
  // we can use [runtimeType + number] as the id for config objects and can
  // change this to Map<String, bool> to store hidden status.
  final List<bool> _hiddenStatus = <bool>[];
  SharedPreferences? _prefs;

  /// List of indicators.
  @override
  List<T> get items => _addOns;

  /// Storage key of saved indicators/drawing tools.
  String get addOnsKey => 'addOns_${T.toString()}_$sharedPrefKey';

  /// Called to create an AddOnConfig object from a map.
  CreateAddOn<T> createAddOn;

  /// Called when the edit icon is clicked.
  OnEditAddOn? onEditCallback;

  /// Called when an add-on is deleted.
  OnDeleteAddOn? onDeleteCallback;

  /// Callback to swap two elements of a list.
  OnSwapCallback? onSwapCallback;

  /// Loads user selected indicators or drawing tools from shared preferences.
  void loadFromPrefs(SharedPreferences prefs, String symbol) {
    _prefs = prefs;
    sharedPrefKey = symbol;

    items.clear();
    _hiddenStatus.clear();

    if (!prefs.containsKey(addOnsKey)) {
      // No saved indicators or drawing tools.
      notifyListeners();
      return;
    }

    final List<String> encodedAddOns = prefs.getStringList(addOnsKey)!;

    final List<Map<String, dynamic>> decodedAddons = encodedAddOns
        .map<Map<String, dynamic>>(
            (String encodedAddOn) => jsonDecode(encodedAddOn))
        .toList();

    for (final Map<String, dynamic> decodedAddon in decodedAddons) {
      final T addOnConfig = createAddOn.call(decodedAddon);
      items.add(addOnConfig);
      _hiddenStatus.add(false);
    }

    notifyListeners();
  }

  /// Adds a new indicator or drawing tool and updates storage.
  @override
  void add(T addOnConfig) {
    items.add(addOnConfig);
    _hiddenStatus.add(false);
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
  void removeAt(int index) {
    if (index < 0 || index >= items.length) {
      return;
    }
    final removedItem = items.removeAt(index);
    _hiddenStatus.removeAt(index);
    _writeToPrefs();
    // Notify about the deletion
    onDeleteCallback?.call(removedItem, index);
    notifyListeners();
  }

  @override
  void remove(T config) {
    final index = items.indexWhere((item) => item.configId == config.configId);
    if (index != -1) {
      removeAt(index);
    }
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
    _hiddenStatus.swap(index1, index2);
    _writeToPrefs();
    onSwapCallback?.call(index1, index2);
    notifyListeners();
  }

  Future<void> _writeToPrefs() async {
    if (_prefs != null) {
      await _prefs!.setStringList(
        addOnsKey,
        items.map((T config) => jsonEncode(config.toJson())).toList(),
      );
    }
  }

  /// Updates the hidden status of an indicator or drawing tool.
  @override
  void updateHiddenStatus({required int index, required bool hidden}) {
    _hiddenStatus[index] = hidden;
    notifyListeners();
  }

  @override
  bool getHiddenStatus(int index) => _hiddenStatus[index];

  @override
  void update() {
    notifyListeners();
  }
}
