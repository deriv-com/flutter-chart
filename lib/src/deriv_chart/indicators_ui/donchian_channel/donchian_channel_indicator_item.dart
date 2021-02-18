import 'package:deriv_chart/deriv_chart.dart';

import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'donchian_channel_indicator_config.dart';

/// Donchian Channel indicator item in the list of indicator which provide this
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
  int _highPeriod;
  int _lowPeriod;
  bool _channelFill;

  @override
  DonchianChannelIndicatorConfig createIndicatorConfig() =>
      DonchianChannelIndicatorConfig(
        highPeriod: _getCurrentHighPeriod(),
        lowPeriod: _getCurrentLowPeriod(),
        showChannelFill: _getCurrentFill(),
      );

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
            ChartLocalization.of(context).labelChannelFill,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Switch(
            value: _getCurrentFill(),
            onChanged: (bool value) {
              setState(() {
                _channelFill = value;
              });
              updateIndicator();
            },
          ),
        ],
      );

  bool _getCurrentFill() =>
      _channelFill ?? getConfig()?.showChannelFill ?? true;

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
              initialValue: _getCurrentHighPeriod().toString(),
              keyboardType: TextInputType.number,
              onChanged: (String text) {
                if (text.isNotEmpty) {
                  _highPeriod = int.tryParse(text);
                } else {
                  _highPeriod = 10;
                }
                updateIndicator();
              },
            ),
          ),
        ],
      );

  int _getCurrentHighPeriod() => _highPeriod ?? getConfig()?.highPeriod ?? 10;

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
              initialValue: _getCurrentLowPeriod().toString(),
              keyboardType: TextInputType.number,
              onChanged: (String text) {
                if (text.isNotEmpty) {
                  _lowPeriod = int.tryParse(text);
                } else {
                  _lowPeriod = 10;
                }
                updateIndicator();
              },
            ),
          ),
        ],
      );

  int _getCurrentLowPeriod() => _lowPeriod ?? getConfig()?.lowPeriod ?? 10;
}
