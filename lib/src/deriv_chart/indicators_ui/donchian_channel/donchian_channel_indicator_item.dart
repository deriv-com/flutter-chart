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
  @override
  DonchianChannelIndicatorConfig createIndicatorConfig() =>
      const DonchianChannelIndicatorConfig();

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          _buildHighPeriodField(),
          _buildLowPeriodField(),
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

  Widget _buildHighPeriodField() => Row(
        children: <Widget>[
          Text(
            // TODO(Rustem): use localization
            'High Period',
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 20,
            child: TextFormField(
              style: const TextStyle(fontSize: 10),
              initialValue: '10',
              keyboardType: TextInputType.number,
              onChanged: (String text) {},
            ),
          ),
        ],
      );

  Widget _buildLowPeriodField() => Row(
        children: <Widget>[
          Text(
            // TODO(Rustem): use localization
            'Low Period',
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 20,
            child: TextFormField(
              style: const TextStyle(fontSize: 10),
              initialValue: '10',
              keyboardType: TextInputType.number,
              onChanged: (String text) {},
            ),
          ),
        ],
      );
}
