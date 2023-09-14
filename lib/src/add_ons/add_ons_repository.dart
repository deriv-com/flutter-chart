import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:deriv_chart/src/add_ons/add_on_config.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Called to create an AddOnConfig object from a map.
typedef CreateAddOn<T extends AddOnConfig> = T Function(
    Map<String, dynamic> map);

/// Holds indicators/drawing tools that were added to the Chart during runtime.
class AddOnsRepository<T extends AddOnConfig> extends ChangeNotifier
    implements Repository<T> {
  /// Initializes
  AddOnsRepository({
    required this.createAddOn,
    required this.currentSymbol,
    this.onEditCallback,
  }) : _addOns = <T>[];

  /// Current symbol.
  String currentSymbol;

  /// List containing addOns
  final List<T> _addOns;
  SharedPreferences? _prefs;

  /// List of indicators.
  @override
  List<T> get items => _addOns;

  /// Storage key of saved indicators/drawing tools.
  String get addOnsKey => 'addOns_${T.toString()}$currentSymbol';

  /// Called to create an AddOnConfig object from a map.
  CreateAddOn<T> createAddOn;

  /// Called when the edit icon is clicked.
  VoidCallback? onEditCallback;

  /// Loads user selected indicators or drawing tools from shared preferences.
  void loadFromPrefs(SharedPreferences prefs, String symbol) {
    _prefs = prefs;
    currentSymbol = symbol;

    items.clear();

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
      final T addOnConfig = createAddOn.call(decodedAddon);
      items.add(addOnConfig);
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
  void editAt(int index) {
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
  void removeAt(int index) {
    if (index < 0 || index >= items.length) {
      return;
    }
    items.removeAt(index);
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
        items.map((AddOnConfig config) => jsonEncode(config)).toList(),
      );
    }
  }
}
