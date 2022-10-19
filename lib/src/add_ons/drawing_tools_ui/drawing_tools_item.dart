import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'callbacks.dart';
import 'drawing_tools_config.dart';
import 'drawing_tools_repository.dart';

/// Representing and drawing tool item in drawing tools list dialog.
abstract class DrawingToolsItem extends StatefulWidget {
  /// Initializes
  const DrawingToolsItem({
    required this.title,
    required this.config,
    required this.updateDrawingTool,
    required this.deleteDrawingTool,
    Key? key,
  }) : super(key: key);

  /// Title
  final String title;

  /// Contains indicator configuration.
  final DrawingToolsConfig config;

  /// Called when config values were updated.
  final UpdateDrawingTool updateDrawingTool;

  /// Called when user removed indicator.
  final VoidCallback deleteDrawingTool;

  @override
  DrawingToolsItemState<DrawingToolsConfig> createState() =>
      createDrawingToolsItemState();

  /// Create state object for this widget
  @protected
  DrawingToolsItemState<DrawingToolsConfig> createDrawingToolsItemState();
}

/// State class of [IndicatorItem]
abstract class DrawingToolsItemState<T extends DrawingToolsConfig>
    extends State<DrawingToolsItem> {
  /// Indicators repository
  @protected
  late DrawingToolsRepository drawingToolsRepo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    drawingToolsRepo = Provider.of<DrawingToolsRepository>(context);
  }

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.all(0),
        leading: Text(widget.title, style: const TextStyle(fontSize: 10)),
        title: getDrawingToolOptions(),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: removeDrawingTool,
        ),
      );

  /// Updates indicator based on its current config values.
  void updateDrawingTool() =>
      widget.updateDrawingTool.call(createDrawingToolConfig());

  /// Removes this indicator.
  void removeDrawingTool() => widget.deleteDrawingTool.call();

  /// Returns the [IndicatorConfig] which can be used to create the Series for
  /// this indicator.
  T createDrawingToolConfig();

  /// Creates the menu options widget for this indicator.
  Widget getDrawingToolOptions();
}
