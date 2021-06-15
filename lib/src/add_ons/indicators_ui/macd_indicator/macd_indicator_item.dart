import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'macd_indicator_config.dart';

/// Ichimoku Cloud indicator item in the list of indicator which provide this
/// indicators options menu.
class MACDIndicatorItem extends IndicatorItem {
  /// Initializes
  const MACDIndicatorItem({
    Key key,
    MACDIndicatorConfig config,
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  }) : super(
          key: key,
          title: 'MACD',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      MACDIndicatorItemState();
}

/// IchimokuCloudIndicatorItem State class
class MACDIndicatorItemState extends IndicatorItemState<MACDIndicatorConfig> {
  int _fastMAPeriod;
  int _slowMAPeriod;
  int _signalPeriod;

  @override
  MACDIndicatorConfig createIndicatorConfig() => MACDIndicatorConfig(
        fastMAPeriod: _currentFastMAPeriod,
        slowMAPeriod: _currentSlowMAPeriod,
        signalPeriod: _currentSignalPeriod,
      );

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          _buildFastMAPeriodField(),
          _buildSlowMAPeriodField(),
          _buildSignalPeriodField(),
        ],
      );

  Widget _buildFastMAPeriodField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelFastMAPeriod,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 20,
            child: TextFormField(
              style: const TextStyle(fontSize: 10),
              initialValue: _currentFastMAPeriod.toString(),
              keyboardType: TextInputType.number,
              onChanged: (String text) {
                if (text.isNotEmpty) {
                  _fastMAPeriod = int.tryParse(text);
                } else {
                  _fastMAPeriod = 12;
                }
                setState(() {
                  updateIndicator();
                });
              },
            ),
          ),
        ],
      );

  Widget _buildSlowMAPeriodField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelSlowMAPeriod,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 20,
            child: TextFormField(
              style: const TextStyle(fontSize: 10),
              initialValue: _currentSlowMAPeriod.toString(),
              keyboardType: TextInputType.number,
              onChanged: (String text) {
                if (text.isNotEmpty) {
                  _slowMAPeriod = int.tryParse(text);
                } else {
                  _slowMAPeriod = 26;
                }
                setState(() {
                  updateIndicator();
                });
              },
            ),
          ),
        ],
      );

  Widget _buildSignalPeriodField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelSignalPeriod,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 20,
            child: TextFormField(
              style: const TextStyle(fontSize: 10),
              initialValue: _currentSignalPeriod.toString(),
              keyboardType: TextInputType.number,
              onChanged: (String text) {
                if (text.isNotEmpty) {
                  _signalPeriod = int.tryParse(text);
                } else {
                  _signalPeriod = 9;
                }
                setState(() {
                  updateIndicator();
                });
              },
            ),
          ),
        ],
      );

  // TOdO(Ramin): Add generic type to avoid casting.
  int get _currentSlowMAPeriod =>
      _slowMAPeriod ??
      (widget.config as MACDIndicatorConfig)?.slowMAPeriod ??
      26;

  int get _currentFastMAPeriod =>
      _fastMAPeriod ??
      (widget.config as MACDIndicatorConfig)?.fastMAPeriod ??
      12;

  int get _currentSignalPeriod =>
      _signalPeriod ??
      (widget.config as MACDIndicatorConfig)?.signalPeriod ??
      9;
}
