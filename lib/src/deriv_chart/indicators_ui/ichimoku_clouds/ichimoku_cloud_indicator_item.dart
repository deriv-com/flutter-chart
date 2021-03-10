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
  int _baseLinePeriod = 26;
  int _conversionLinePeriod = 9;
  int _spanBPeriod = 52;
  int _laggingSpanOffset = -26;

  @override
  IchimokuCloudIndicatorConfig createIndicatorConfig() =>
      IchimokuCloudIndicatorConfig(
        baseLinePeriod: _baseLinePeriod,
        conversionLinePeriod: _conversionLinePeriod,
        laggingSpanOffset: _laggingSpanOffset,
        spanBPeriod: _spanBPeriod,
      );

  Widget _buildConversionLinePeriodField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelConversionLinePeriod,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 20,
            child: TextFormField(
              style: const TextStyle(fontSize: 10),
              initialValue: _conversionLinePeriod.toString(),
              keyboardType: TextInputType.number,
              onChanged: (String text) {
                if (text.isNotEmpty) {
                  _conversionLinePeriod = int.tryParse(text);
                } else {
                  _conversionLinePeriod = 9;
                }
                updateIndicator();
              },
            ),
          ),
        ],
      );

  Widget _buildBaseLinePeriodField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelBaseLinePeriod,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 20,
            child: TextFormField(
              style: const TextStyle(fontSize: 10),
              initialValue: _baseLinePeriod.toString(),
              keyboardType: TextInputType.number,
              onChanged: (String text) {
                if (text.isNotEmpty) {
                  _baseLinePeriod = int.tryParse(text);
                } else {
                  _baseLinePeriod = 26;
                }
                updateIndicator();
              },
            ),
          ),
        ],
      );

  Widget _buildSpanBPeriodField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelSpanBPeriod,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 20,
            child: TextFormField(
              style: const TextStyle(fontSize: 10),
              initialValue: _spanBPeriod.toString(),
              keyboardType: TextInputType.number,
              onChanged: (String text) {
                if (text.isNotEmpty) {
                  _spanBPeriod = int.tryParse(text);
                } else {
                  _spanBPeriod = 26;
                }
                updateIndicator();
              },
            ),
          ),
        ],
      );

  Widget _buildOffsetField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelLaggingSpanOffset,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Slider(
              value: _laggingSpanOffset.abs().toDouble(),
              onChanged: (double value) {
                setState(() {
                  _laggingSpanOffset = value.toInt() * -1;
                  updateIndicator();
                });
              },
              divisions: 100,
              max: 100,
              label: '${_laggingSpanOffset.abs()}',
            ),
          ),
        ],
      );

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          _buildBaseLinePeriodField(),
          _buildConversionLinePeriodField(),
          _buildSpanBPeriodField(),
          _buildOffsetField(),
        ],
      );
}
