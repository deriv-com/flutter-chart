import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'callbacks.dart';
import 'indicator_config.dart';
import 'indicator_repository.dart';

/// Representing and indicator item in indicators list dialog.
abstract class IndicatorItem extends StatefulWidget {
  /// Initializes
  const IndicatorItem({
    Key key,
    this.title,
    this.indicatorConfig,
    this.updateIndicator,
    this.deleteIndicator,
  }) : super(key: key);

  /// Title
  final String title;

  final IndicatorConfig indicatorConfig;

  final Function updateIndicator;
  final Function deleteIndicator;

  @override
  IndicatorItemState<IndicatorConfig> createState() =>
      createIndicatorItemState();

  /// Create state object for this widget
  @protected
  IndicatorItemState<IndicatorConfig> createIndicatorItemState();
}

/// State class of [IndicatorItem]
abstract class IndicatorItemState<T extends IndicatorConfig>
    extends State<IndicatorItem> {
  /// Indicators repository
  @protected
  IndicatorsRepository indicatorsRepo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    indicatorsRepo = Provider.of<IndicatorsRepository>(context);
  }

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.all(0),
        leading: Text(widget.title, style: const TextStyle(fontSize: 10)),
        title: getIndicatorOptions(),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: removeIndicator,
        ),
      );

  /// Updates indicator based on its current config values.
  void updateIndicator() =>
      widget.updateIndicator?.call(createIndicatorConfig());

  /// Removes this indicator.
  void removeIndicator() => widget.deleteIndicator.call();

  /// Returns the [IndicatorConfig] which can be used to create the Series for this indicator.
  T createIndicatorConfig();

  /// Gets the [IndicatorConfig] of this [IndicatorItem]
  T getConfig() => indicatorsRepo != null
      ? indicatorsRepo?.indicators[getIndicatorKey()]
      : null;

  /// Creates the menu options widget for this indicator.
  Widget getIndicatorOptions();
}
