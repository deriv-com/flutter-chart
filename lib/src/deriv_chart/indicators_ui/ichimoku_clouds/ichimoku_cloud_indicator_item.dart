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
        baseLinePeriod: _currentBaseLinePeriod,
        conversionLinePeriod: _currentConversionLinePeriod,
        laggingSpanOffset: _currentLaggingSpanOffset,
        spanBPeriod: _currentSpanBPeriod,
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
              initialValue: _currentConversionLinePeriod.toString(),
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
              initialValue: _currentBaseLinePeriod.toString(),
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
              initialValue: _currentSpanBPeriod.toString(),
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
              value: _currentLaggingSpanOffset.abs().toDouble(),
              onChanged: (double value) {
                setState(() {
                  _laggingSpanOffset = value.toInt() * -1;
                  updateIndicator();
                });
              },
              divisions: 100,
              max: 100,
              label: '${_currentLaggingSpanOffset.abs()}',
            ),
          ),
        ],
      );

  int get _currentBaseLinePeriod =>
      _baseLinePeriod ?? getConfig()?.baseLinePeriod ?? 26;
  int get _currentConversionLinePeriod =>
      _conversionLinePeriod ?? getConfig()?.conversionLinePeriod ?? 9;
  int get _currentSpanBPeriod => _spanBPeriod ?? getConfig()?.spanBPeriod ?? 52;
  int get _currentLaggingSpanOffset =>
      _laggingSpanOffset ?? getConfig()?.laggingSpanOffset ?? -26;
}
