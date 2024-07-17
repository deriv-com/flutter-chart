import 'package:flutter/material.dart';

import 'add_on_config_wrapper.dart';

/// Holds indicators/drawing tools that were added to the Chart during runtime.
abstract class Repository<T> extends ChangeNotifier {
  /// Retrieves the list of items in a repository.
  List<AddOnConfigWrapper<T>> get items;

  /// To adds a new indicator or drawing tool.
  void add(AddOnConfigWrapper<T> config);

  /// Edits an existing indicator or drawing tool at the specified [index].
  /// This method allows you to modify the settings and properties of the
  /// indicator or tool
  /// without changing its position in the list.
  void editAt(int index);

  /// Updates an existing indicator or drawing tool at the
  /// specified [index] with new configuration settings.
  /// This method allows you to modify the indicator or tool's properties
  /// while preserving its position in the list.
  void updateAt(int index, AddOnConfigWrapper<T> config);

  /// Removes indicator or drawing tool at [index].
  void removeAt(int index);

  /// Swaps two elements of a list.
  void swap(int index1, int index2);

  /// Clears all indicator and drawing tools
  void clear();

  /// Updates the hidden status of an indicator or drawing tool.
  void updateHiddenStatus({
    required AddOnConfigWrapper<T> addOn,
    required bool hidden,
  });

  /// Retrieves the hidden status of an indicator or drawing tool.
  bool getHiddenStatus(AddOnConfigWrapper<T> addOn);
}
