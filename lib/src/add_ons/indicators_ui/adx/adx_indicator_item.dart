import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/field_widget.dart';

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
  int? _period;
  int? _smoothingPeriod;
  bool? _channelFill;
  bool? _showHistogram;
  bool? _showSeries;

  @override
  ADXIndicatorConfig createIndicatorConfig() => ADXIndicatorConfig(
        period: _currentPeriod,
        smoothingPeriod: _currentSmoothingPeriod,
        showChannelFill: _currentChannelFill,
        showSeries: _currentShowSeries,
        showHistogram: _currentShowHistogram,
      );

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          _buildPeriodField(),
          _buildSmoothingPeriodField(),
          _buildShowSeriesToggle(),
          // _buildChannelFillToggle(),
          _buildShowHistogramToggle()
        ],
      );

  // TODO(mohammadamir): Add Shading after channel Fill is done
  // Widget _buildChannelFillToggle() => Row(
  //       children: <Widget>[
  //         Text(
  //           ChartLocalization.of(context).labelShading,
  //           style: const TextStyle(fontSize: 10),
  //         ),
  //         const SizedBox(width: 4),
  //         Switch(
  //           value: _currentChannelFill,
  //           onChanged: (bool value) {
  //             setState(() {
  //               _channelFill = value;
  //             });
  //             updateIndicator();
  //           },
  //         ),
  //       ],
  //     );

  Widget _buildShowSeriesToggle() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelSeries,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Switch(
            value: _currentShowSeries,
            onChanged: (bool value) {
              setState(() {
                _showSeries = value;
              });
              updateIndicator();
            },
          ),
        ],
      );

  Widget _buildShowHistogramToggle() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelHistogram,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Switch(
            value: _currentShowHistogram,
            onChanged: (bool value) {
              setState(() {
                _showHistogram = value;
              });
              updateIndicator();
            },
          ),
        ],
      );

  Widget _buildSmoothingPeriodField() => FieldWidget(
        initialValue: _currentSmoothingPeriod.toString(),
        label: ChartLocalization.of(context).labelSmoothingPeriod,
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _smoothingPeriod = int.tryParse(text);
          } else {
            _smoothingPeriod = 14;
          }
          updateIndicator();
        },
      );

  Widget _buildPeriodField() => FieldWidget(
        initialValue: _currentPeriod.toString(),
        label: ChartLocalization.of(context).labelPeriod,
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _period = int.tryParse(text);
          } else {
            _period = 14;
          }
          updateIndicator();
        },
      );

  int get _currentPeriod =>
      _period ?? (widget.config as ADXIndicatorConfig).period;

  int get _currentSmoothingPeriod =>
      _smoothingPeriod ?? (widget.config as ADXIndicatorConfig).period;

  bool get _currentChannelFill =>
      _channelFill ?? (widget.config as ADXIndicatorConfig).showChannelFill;

  bool get _currentShowHistogram =>
      _showHistogram ?? (widget.config as ADXIndicatorConfig).showHistogram;

  bool get _currentShowSeries =>
      _showSeries ?? (widget.config as ADXIndicatorConfig).showSeries;
}
