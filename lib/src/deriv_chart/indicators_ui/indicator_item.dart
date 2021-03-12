import 'package:deriv_chart/src/models/tick.dart';
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
    this.ticks,
    this.onAddIndicator,
  }) : super(key: key);

  /// Title
  final String title;

  /// List of entries to calculate indicator on.
  final List<Tick> ticks;

  /// A callback which will be called when want to add this indicator.
  final OnAddIndicator onAddIndicator;

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
          icon: const Icon(Icons.add),
          onPressed: () {
            widget.onAddIndicator?.call(createIndicatorConfig());
          },
        ),
      );

  /// Gets the key for this indicator
  @protected
  String getIndicatorKey() => runtimeType.toString();

  /// Returns the [IndicatorConfig] which can be used to create the Series for this indicator.
  T createIndicatorConfig();

  /// Gets the [IndicatorConfig] of this [IndicatorItem]
  T getConfig() => indicatorsRepo != null
      ? indicatorsRepo?.indicators[getIndicatorKey()]
      : null;

  /// Creates the menu options widget for this indicator.
  Widget getIndicatorOptions();
}
