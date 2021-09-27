import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/oscillator_lines/oscillator_lines_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/field_widget.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/oscillator_limit.dart';

import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'cci_indicator_config.dart';

/// Commodity Channel Index indicator item in the list of indicator which
/// provides this indicators options menu.
class CCIIndicatorItem extends IndicatorItem {
  /// Initializes
  const CCIIndicatorItem({
    required UpdateIndicator updateIndicator,
    required VoidCallback deleteIndicator,
    Key? key,
    CCIIndicatorConfig config = const CCIIndicatorConfig(),
  }) : super(
          key: key,
          title: 'Commodity Channel Index',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      CCIIndicatorItemState();
}

/// CCIItem State class
class CCIIndicatorItemState extends IndicatorItemState<CCIIndicatorConfig> {
  int? _period;
  double? _overboughtValue;
  double? _oversoldValue;
  LineStyle? _overboughtStyle;
  LineStyle? _oversoldStyle;
  bool? _showZones;

  @override
  CCIIndicatorConfig createIndicatorConfig() => CCIIndicatorConfig(
        period: _currentPeriod,
        oscillatorLinesConfig: OscillatorLinesConfig(
          overboughtValue: _currentOverBoughtPrice,
          oversoldValue: _currentOverSoldPrice,
          overboughtStyle: _currentOverboughtStyle,
          oversoldStyle: _currentOversoldStyle,
        ),
        showZones: _currentShowZones,
      );

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          _buildPeriodField(),
          _buildOverBoughtPriceField(),
          _buildOverSoldPriceField(),
          _buildShowZonesField(),
        ],
      );

  Widget _buildShowZonesField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelShowZones,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Switch(
            value: _currentShowZones,
            onChanged: (bool value) {
              setState(() {
                _showZones = value;
              });
              updateIndicator();
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          ),
        ],
      );

  Widget _buildPeriodField() => FieldWidget(
        initialValue: _currentPeriod.toString(),
        label: ChartLocalization.of(context).labelPeriod,
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _period = int.tryParse(text);
          } else {
            _period = 20;
          }
          updateIndicator();
        },
      );

  // TODO(Ramin): use generic type in widget class as well for the config.
  int get _currentPeriod =>
      _period ?? (widget.config as CCIIndicatorConfig).period;

  Widget _buildOverBoughtPriceField() => OscillatorLimit(
        label: ChartLocalization.of(context).labelOverBoughtPrice,
        value: _currentOverBoughtPrice,
        color: _currentOverboughtStyle.color,
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _overboughtValue = double.tryParse(text);
          } else {
            _overboughtValue = 100;
          }
          updateIndicator();
        },
        onColorChanged: (Color selectedColor) {
          setState(() {
            _overboughtStyle =
                _currentOverboughtStyle.copyWith(color: selectedColor);
          });
          updateIndicator();
        },
      );

  double get _currentOverBoughtPrice =>
      _overboughtValue ??
      (widget.config as CCIIndicatorConfig)
          .oscillatorLinesConfig
          .overboughtValue;

  Widget _buildOverSoldPriceField() => OscillatorLimit(
        label: ChartLocalization.of(context).labelOverSoldPrice,
        value: _currentOverSoldPrice,
        color: _currentOversoldStyle.color,
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _oversoldValue = double.tryParse(text);
          } else {
            _oversoldValue = -100;
          }
          updateIndicator();
        },
        onColorChanged: (Color selectedColor) {
          setState(() {
            _oversoldStyle =
                _currentOversoldStyle.copyWith(color: selectedColor);
          });
          updateIndicator();
        },
      );

  double get _currentOverSoldPrice =>
      _oversoldValue ??
      (widget.config as CCIIndicatorConfig).oscillatorLinesConfig.oversoldValue;

  LineStyle get _currentOverboughtStyle =>
      _overboughtStyle ??
      (widget.config as CCIIndicatorConfig)
          .oscillatorLinesConfig
          .overboughtStyle;

  LineStyle get _currentOversoldStyle =>
      _oversoldStyle ??
      (widget.config as CCIIndicatorConfig).oscillatorLinesConfig.oversoldStyle;

  bool get _currentShowZones =>
      _showZones ?? (widget.config as CCIIndicatorConfig).showZones;
}
