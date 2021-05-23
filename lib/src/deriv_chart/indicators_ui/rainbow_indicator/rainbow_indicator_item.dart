import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/ma_indicator/ma_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/ma_indicator/ma_indicator_item.dart';

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
    Key key,
    RainbowIndicatorConfig config,
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
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
  int bandsCount;

  @override
  MAIndicatorConfig createIndicatorConfig() => RainbowIndicatorConfig(
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
        (widget.config as RainbowIndicatorConfig);
    return bandsCount ?? config?.bandsCount ?? 10;
  }

  /// Gets Indicator current period.
  @override
  int getCurrentPeriod() =>
      period ?? (widget.config as RainbowIndicatorConfig)?.period ?? 2;
}
