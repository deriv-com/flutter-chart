import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deriv_chart/src/add_ons/repository.dart';

import 'callbacks.dart';
import 'indicator_config.dart';

/// Representing and indicator item in indicators list dialog.
abstract class IndicatorItem extends StatefulWidget {
  /// Initializes
  const IndicatorItem({
    required this.title,
    required this.config,
    required this.updateIndicator,
    required this.deleteIndicator,
    Key? key,
  }) : super(key: key);

  /// Title
  @Deprecated('The widget uses config.shortTitle instead.')
  final String title;

  /// Contains indicator configuration.
  final IndicatorConfig config;

  /// Called when config values were updated.
  final UpdateIndicator updateIndicator;

  /// Called when user removed indicator.
  final VoidCallback deleteIndicator;

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
  late Repository<IndicatorConfig> indicatorsRepo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    indicatorsRepo = Provider.of<Repository<IndicatorConfig>>(context);
  }

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.all(0),
        leading: Text(
          '${widget.config.shortTitle}'
          ' ${widget.config.number > 0 ? widget.config.number : ''}',
          style: const TextStyle(fontSize: 10),
        ),
        title: getIndicatorOptions(),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: removeIndicator,
        ),
      );

  /// Updates indicator based on its current config values.
  void updateIndicator() =>
      widget.updateIndicator.call(updateIndicatorConfig());

  /// Removes this indicator.
  void removeIndicator() => widget.deleteIndicator.call();

  /// Updates the current [widget.config] with the latest values set in menus
  /// options and returns the updated config.
  T updateIndicatorConfig();

  /// Creates the menu options widget for this indicator.
  Widget getIndicatorOptions();
}
