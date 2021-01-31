import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/indicators_ui/ichimoku_clouds/ichimoku_cloud_indicator_config.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';

/// Ichimoku Cloud indicator item in the list of indicator which provide this
/// indicators options menu.
class IchimokuCloudIndicatorItem extends IndicatorItem {
  /// Initializes
  const IchimokuCloudIndicatorItem({
    Key key,
    List<Tick> ticks,
    OnAddIndicator onAddIndicator,
  }) : super(
          key: key,
          title: 'Ichimoku Cloud',
          ticks: ticks,
          onAddIndicator: onAddIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      IchimokuCloudIndicatorItemState();
}

/// IchimokuCloudIndicatorItem State class
class IchimokuCloudIndicatorItemState
    extends IndicatorItemState<IchimokuCloudIndicatorConfig> {
  @override
  IchimokuCloudIndicatorConfig createIndicatorConfig() =>
      const IchimokuCloudIndicatorConfig();

  @override
  Widget getIndicatorOptions() => const SizedBox.shrink();
}
