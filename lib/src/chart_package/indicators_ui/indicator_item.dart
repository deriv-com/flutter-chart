import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'callbacks.dart';
import 'indicator_config.dart';
import 'indicator_repository.dart';

/// Indicator item in indicators dialog
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
  IndicatorItemState createState() => createIndicatorItemState();

  @protected
  IndicatorItemState createIndicatorItemState();
}

/// State class of [IndicatorItem]
abstract class IndicatorItemState<T extends IndicatorConfig>
    extends State<IndicatorItem> {
  @protected
  IndicatorsRepository indicatorsRepo;

  /// Gets the [IndicatorConfig] of this [IndicatorItem]
  T getConfig() => indicatorsRepo != null
      ? indicatorsRepo?.indicators[getIndicatorKey()]
      : null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    indicatorsRepo = Provider.of<IndicatorsRepository>(context);
  }

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Text(widget.title, style: const TextStyle(fontSize: 12)),
        title: getIndicatorOptions(),
        trailing: Checkbox(
          value: indicatorsRepo.isIndicatorActive(getIndicatorKey()),
          onChanged: (bool newValue) => setState(
            () {
              if (newValue) {
                widget.onAddIndicator?.call(
                  getIndicatorKey(),
                  createIndicatorConfig(),
                );
              } else {
                widget.onAddIndicator?.call(getIndicatorKey(), null);
              }
            },
          ),
        ),
      );

  @protected
  String getIndicatorKey() => runtimeType.toString();

  /// Returns the [IndicatorConfig] which can be used to create the [Series] for this indicator.
  IndicatorConfig createIndicatorConfig();

  /// Creates the menu options widget for this indicator.
  Widget getIndicatorOptions();
}
