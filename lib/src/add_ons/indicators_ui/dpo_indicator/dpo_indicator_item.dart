import 'package:deriv_chart/src/add_ons/indicators_ui/ma_indicator/ma_indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/ma_indicator/ma_indicator_item.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'dpo_indicator_config.dart';

/// Detrended Price Oscillator indicator item in the list of indicator which
/// provide this indicators options menu.
class DPOIndicatorItem extends IndicatorItem {
  /// Initializes
  const DPOIndicatorItem({
    required UpdateIndicator updateIndicator,
    required VoidCallback deleteIndicator,
    Key? key,
    DPOIndicatorConfig config = const DPOIndicatorConfig(),
  }) : super(
          key: key,
          title: 'DPO',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      DPOIndicatorItemState();
}

/// DpoIndicatorItem State class
class DPOIndicatorItemState extends MAIndicatorItemState {
  @override
  DPOIndicatorConfig createIndicatorConfig() =>
      (widget.config as DPOIndicatorConfig).copyWith(
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
        ],
      );

  @override
  int getCurrentPeriod() =>
      period ?? (widget.config as MAIndicatorConfig).period;
}
