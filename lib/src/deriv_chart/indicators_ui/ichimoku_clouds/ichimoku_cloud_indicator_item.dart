import 'package:deriv_chart/deriv_chart.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'ichimoku_cloud_indicator_config.dart';

/// Ichimoku Cloud indicator item in the list of indicator which provide this
/// indicators options menu.
class IchimokuCloudIndicatorItem extends IndicatorItem {
  /// Initializes
  const IchimokuCloudIndicatorItem({
    Key key,
    IchimokuCloudIndicatorConfig config,
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  }) : super(
          key: key,
          title: 'Ichimoku',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      IchimokuCloudIndicatorItemState();
}

/// IchimokuCloudIndicatorItem State class
class IchimokuCloudIndicatorItemState
    extends IndicatorItemState<IchimokuCloudIndicatorConfig> {
  int _baseLinePeriod;
  int _conversionLinePeriod;
  int _spanBPeriod;
  int _laggingSpanOffset;

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
                setState(() {
                  updateIndicator();
                });
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
                setState(() {
                  updateIndicator();
                });
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
                setState(() {
                  updateIndicator();
                });
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

  // TOdO(Ramin): Add generic type to avoid casting.
  int get _currentBaseLinePeriod =>
      _baseLinePeriod ??
      (widget.config as IchimokuCloudIndicatorConfig)?.baseLinePeriod ??
      26;

  int get _currentConversionLinePeriod =>
      _conversionLinePeriod ??
      (widget.config as IchimokuCloudIndicatorConfig)?.conversionLinePeriod ??
      9;

  int get _currentSpanBPeriod =>
      _spanBPeriod ??
      (widget.config as IchimokuCloudIndicatorConfig)?.spanBPeriod ??
      52;

  int get _currentLaggingSpanOffset =>
      _laggingSpanOffset ??
      (widget.config as IchimokuCloudIndicatorConfig)?.laggingSpanOffset ??
      -26;
}
