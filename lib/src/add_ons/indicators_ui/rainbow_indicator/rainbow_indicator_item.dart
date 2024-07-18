import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/ma_indicator/ma_indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/ma_indicator/ma_indicator_item.dart';

import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'rainbow_indicator_config.dart';

/// Rainbow indicator item in the list of indicator which provide this
/// indicators options menu.
class RainbowIndicatorItem extends IndicatorItem {
  /// Initializes
  const RainbowIndicatorItem({
    required RainbowIndicatorConfig config,
    required UpdateIndicator updateIndicator,
    required VoidCallback deleteIndicator,
    Key? key,
  }) : super(
          key: key,
          title: 'Rainbow Indicator',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      RainbowIndicatorItemState();
}

/// Rainbow IndicatorItem State class
class RainbowIndicatorItemState extends MAIndicatorItemState {
  /// Rainbow MA bands count
  @protected
  int? bandsCount;

  @override
  MAIndicatorConfig createIndicatorConfig() =>
      (widget.config as RainbowIndicatorConfig).copyWith(
        bandsCount: getCurrentBandsCount(),
        period: getCurrentPeriod(),
        movingAverageType: getCurrentType(),
        fieldType: getCurrentField(),
      );

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          buildMATypeMenu(),
          Row(
            children: <Widget>[
              buildPeriodField(),
              const SizedBox(width: 10),
              buildFieldTypeMenu()
            ],
          ),
          buildBandsCountField(),
        ],
      );

  /// Renders Indicator's bands
  @protected
  Widget buildBandsCountField() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelBandsCount,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(height: 2),
          Slider(
            value: getCurrentBandsCount().toDouble(),
            min: 1,
            max: 20,
            divisions: 20,
            label: '${getCurrentBandsCount()}',
            onChanged: (double value) {
              setState(() {
                bandsCount = value.toInt();
              });
              updateIndicator();
            },
          ),
        ],
      );

  /// Gets Indicator current period.
  @protected
  int getCurrentBandsCount() {
    final RainbowIndicatorConfig config =
        widget.config as RainbowIndicatorConfig;
    return bandsCount ?? config.bandsCount;
  }

  /// Gets Indicator current period.
  @override
  int getCurrentPeriod() =>
      period ?? (widget.config as RainbowIndicatorConfig).period;
}
