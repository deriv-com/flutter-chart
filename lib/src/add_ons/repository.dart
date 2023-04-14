import 'package:flutter/material.dart';

/// Holds indicators/drawing tools that were added to the Chart during runtime.
abstract class Repository<T> extends ChangeNotifier {
  /// Retrieves the list of items in a repository.
  List<T> get items;

  /// To adds a new indicator or drawing tool.
  void add(T config);

  /// To edit an indicator or drawing tool by [config].
  void edit(T config);

  /// To update an indicator or drawing tool at [index].
  void updateAt(int index, T config);

  /// Removes indicator/drawing tool by [config].
  void remove(T config);
}
