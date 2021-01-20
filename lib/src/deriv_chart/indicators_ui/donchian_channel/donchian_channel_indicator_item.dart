import 'package:deriv_chart/deriv_chart.dart';

import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'donchian_channel_indicator_config.dart';

/// Bollinger Bands indicator item in the list of indicator which provide this
/// indicators options menu.
class DonchianChannelIndicatorItem extends IndicatorItem {
  /// Initializes
  const DonchianChannelIndicatorItem({
    Key key,
    List<Tick> ticks,
    OnAddIndicator onAddIndicator,
  }) : super(
          key: key,
          title: 'Donchian Channel',
          ticks: ticks,
          onAddIndicator: onAddIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      DonchianChannelIndicatorItemState();
}

/// DonchianChannelIndicatorItem State class
class DonchianChannelIndicatorItemState
    extends IndicatorItemState<DonchianChannelIndicatorConfig> {
  double _standardDeviation;

  @override
  DonchianChannelIndicatorConfig createIndicatorConfig() =>
      DonchianChannelIndicatorConfig(
        period: 10,
        movingAverageType: MovingAverageType.simple,
        standardDeviation: _getCurrentStandardDeviation(),
        fieldType: 'close',
      );

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              // buildPeriodField(),
              const SizedBox(width: 10),
            ],
          ),
          _buildChannelFillToggle(),
        ],
      );

  Widget _buildChannelFillToggle() => Row(
        children: <Widget>[
          Text(
            // TODO(Rustem): use localization
            'Channel Fill',
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Switch(value: false, onChanged: (bool value) {}),
        ],
      );

  double _getCurrentStandardDeviation() {
    final DonchianChannelIndicatorConfig config = getConfig();
    return _standardDeviation ?? config?.standardDeviation ?? 2;
  }
}
