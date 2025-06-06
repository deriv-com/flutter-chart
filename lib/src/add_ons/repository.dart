import 'package:flutter/material.dart';

/// Holds indicators/drawing tools that were added to the Chart during runtime.
abstract class Repository<T> extends ChangeNotifier {
  /// Retrieves the list of items in a repository.
  List<T> get items;

  /// To adds a new indicator or drawing tool.
  void add(T config);

  /// Edits an existing indicator or drawing tool at the specified [index].
  /// This method allows you to modify the settings and properties of the
  /// indicator or tool
  /// without changing its position in the list.
  void editAt(int index);

  /// Updates an existing indicator or drawing tool at the
  /// specified [index] with new configuration settings.
  /// This method allows you to modify the indicator or tool's properties
  /// while preserving its position in the list.
  void updateAt(int index, T config);

  /// Removes indicator or drawing tool at [index].
  void removeAt(int index);

  /// Removes a specific indicator or drawing tool from the repository.
  void remove(T config);

  /// Swaps two elements of a list.
  void swap(int index1, int index2);

  /// Clears all indicator and drawing tools
  void clear();

  /// Updates the hidden status of an indicator or drawing tool.
  void updateHiddenStatus({required int index, required bool hidden});

  /// Retrieves the hidden status of an indicator or drawing tool.
  bool getHiddenStatus(int index);

  /// Triggers an update to the repository to update its listeners.
  void update();
}
