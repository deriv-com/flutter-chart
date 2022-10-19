import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'drawing_tools_config.dart';

/// Storage key of saved drawing tools.
const String drawingToolsKey = 'drawing_tools';

/// Holds drawing tools that were added to the Chart during runtime.
class DrawingToolsRepository extends ChangeNotifier {
  /// Initializes
  DrawingToolsRepository() : _drawingTools = <DrawingToolsConfig>[];

  final List<DrawingToolsConfig> _drawingTools;
  SharedPreferences? _prefs;

  /// List of drawing tools.
  List<DrawingToolsConfig> get drawingTools => _drawingTools;

  /// Loads user selected drawing tools from shared preferences.
  void loadFromPrefs(SharedPreferences prefs) {
    _prefs = prefs;

    if (!prefs.containsKey(drawingToolsKey)) {
      // No saved drawing tools.
      return;
    }

    final List<String> strings = prefs.getStringList(drawingToolsKey)!;
    _drawingTools.clear();

    for (final String string in strings) {
      final DrawingToolsConfig drawingToolsConfig =
      DrawingToolsConfig.fromJson(jsonDecode(string));
      _drawingTools.add(drawingToolsConfig);
    }
    notifyListeners();
  }

  /// Adds a new drawing tool and updates storage.
  void add(DrawingToolsConfig drawingToolsConfig) {
    _drawingTools.add(drawingToolsConfig);
    _writeToPrefs();
    notifyListeners();
  }

  /// Updates drawing tool at [index] and updates storage.
  void updateAt(int index, DrawingToolsConfig drawingToolsConfig) {
    if (index < 0 || index >= _drawingTools.length) {
      return;
    }
    _drawingTools[index] = drawingToolsConfig;
    _writeToPrefs();
    notifyListeners();
  }

  /// Removes drawing tool at [index] from repository and updates storage.
  void removeAt(int index) {
    if (index < 0 || index >= _drawingTools.length) {
      return;
    }
    _drawingTools.removeAt(index);
    _writeToPrefs();
    notifyListeners();
  }

  Future<void> _writeToPrefs() async {
    if (_prefs != null) {
      await _prefs!.setStringList(
        drawingToolsKey,
        _drawingTools
            .map((DrawingToolsConfig config) => jsonEncode(config))
            .toList(),
      );
    }
  }
}
