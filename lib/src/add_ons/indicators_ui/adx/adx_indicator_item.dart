import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/deriv_chart.dart';

import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'adx_indicator_config.dart';

/// ADX indicator item in the list of indicator which provide this
/// indicators options menu.
class ADXIndicatorItem extends IndicatorItem {
  /// Initializes
  const ADXIndicatorItem({
    required UpdateIndicator updateIndicator,
    required VoidCallback deleteIndicator,
    Key? key,
    ADXIndicatorConfig config = const ADXIndicatorConfig(),
  }) : super(
          key: key,
          title: 'ADX',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      ADXIndicatorItemState();
}

/// ADXIndicatorItem State class
class ADXIndicatorItemState extends IndicatorItemState<ADXIndicatorConfig> {
  int? _highPeriod;
  int? _lowPeriod;
  bool? _channelFill;

  @override
  ADXIndicatorConfig createIndicatorConfig() => ADXIndicatorConfig(
        period: _getCurrentHighPeriod(),
        lowPeriod: _getCurrentLowPeriod(),
        showChannelFill: _getCurrentFill(),
      );

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[],
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
      _channelFill ??
      (widget.config as DonchianChannelIndicatorConfig).showChannelFill;

  Widget _buildHighPeriodField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelHighPeriod,
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

  int _getCurrentHighPeriod() =>
      _highPeriod ??
      (widget.config as DonchianChannelIndicatorConfig).highPeriod;

  Widget _buildLowPeriodField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelLowPeriod,
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

  int _getCurrentLowPeriod() =>
      _lowPeriod ?? (widget.config as DonchianChannelIndicatorConfig).lowPeriod;
}
