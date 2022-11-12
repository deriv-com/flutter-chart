import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deriv_chart/src/add_ons/add_ons_repository.dart';

import 'callbacks.dart';
import 'drawing_tool_config.dart';

/// Representing a drawing tool item in drawing tools list dialog.
abstract class DrawingToolItem extends StatefulWidget {
  /// Initializes
  const DrawingToolItem({
    required this.title,
    required this.config,
    required this.updateDrawingTool,
    required this.deleteDrawingTool,
    Key? key,
  }) : super(key: key);

  /// Title
  final String title;

  /// Contains drawing tool configuration.
  final DrawingToolConfig config;

  /// Called when config values were updated.
  final UpdateDrawingTool updateDrawingTool;

  /// Called when user removed drawing tool.
  final VoidCallback deleteDrawingTool;

  @override
  DrawingToolItemState<DrawingToolConfig> createState() =>
      createIndicatorItemState();

  /// Create state object for this widget
  @protected
  DrawingToolItemState<DrawingToolConfig> createIndicatorItemState();
}

/// State class of [DrawingToolItem]
abstract class DrawingToolItemState<T extends DrawingToolConfig>
    extends State<DrawingToolItem> {
  /// Indicators repository
  @protected
  late AddOnsRepository<DrawingToolConfig> drawingToolsRepo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    drawingToolsRepo =
        Provider.of<AddOnsRepository<DrawingToolConfig>>(context);
  }

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.all(0),
        title: Text(widget.title, style: const TextStyle(fontSize: 14)),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: removeDrawingTool,
        ),
      );

  /// Updates drawing tool based on its current config values.
  void updateDrawingTool() =>
      widget.updateDrawingTool.call(createDrawingToolConfig());

  /// Removes this drawing tool.
  void removeDrawingTool() => widget.deleteDrawingTool.call();

  /// Returns the [DrawingToolConfig] which can be used to create the Series for
  /// this drawing tool.
  T createDrawingToolConfig();
}
