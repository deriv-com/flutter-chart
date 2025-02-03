import 'package:deriv_chart/generated/l10n.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/indicator_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/oscillator_lines/oscillator_lines_config.dart';
import 'package:deriv_chart/src/add_ons/indicators_ui/widgets/oscillator_limit.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../callbacks.dart';
import '../indicator_item.dart';
import 'bop_indicator_config.dart';

/// Balance of Power (BOP) indicator item.
class BOPIndicatorItem extends IndicatorItem {
  /// Initializes
  const BOPIndicatorItem({
    required UpdateIndicator updateIndicator,
    required VoidCallback deleteIndicator,
    Key? key,
    BOPIndicatorConfig config = const BOPIndicatorConfig(),
  }) : super(
          key: key,
          title: 'BOP',
          config: config,
          updateIndicator: updateIndicator,
          deleteIndicator: deleteIndicator,
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      BOPIndicatorItemState();
}

/// BOPItem State class
class BOPIndicatorItemState extends IndicatorItemState<BOPIndicatorConfig> {
  int? _period;
  double? _overBoughtPrice;
  double? _overSoldPrice;
  LineStyle? _lineStyle;
  LineStyle? _overboughtStyle;
  LineStyle? _oversoldStyle;
  bool? _showZones;
  bool? _pinLabels;

  @override
  BOPIndicatorConfig updateIndicatorConfig() =>
      (widget.config as BOPIndicatorConfig).copyWith(
        period: _getCurrentPeriod(),
        lineStyle: _currentLineStyle,
        oscillatorLinesConfig: OscillatorLinesConfig(
          overboughtValue: _getCurrentOverBoughtPrice(),
          oversoldValue: _getCurrentOverSoldPrice(),
          overboughtStyle: _currentOverboughtStyle,
          oversoldStyle: _currentOversoldStyle,
        ),
        showZones: _currentShowZones,
        pinLabels: _currentPinLabels,
      );

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          _buildPeriodField(),
          _buildLineStyleField(),
          _buildOverBoughtPriceField(),
          _buildOverSoldPriceField(),
          _buildShowZonesField(),
          _buildPinLabelsField(),
        ],
      );

  Widget _buildPeriodField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelPeriod,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 20,
            child: TextFormField(
              style: const TextStyle(fontSize: 10),
              initialValue: _getCurrentPeriod().toString(),
              keyboardType: TextInputType.number,
              onChanged: (String text) {
                if (text.isNotEmpty) {
                  _period = int.tryParse(text);
                } else {
                  _period = 14;
                }
                updateIndicator();
              },
            ),
          ),
        ],
      );

  Widget _buildLineStyleField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelLineStyle,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Container(
              width: 16,
              height: 16,
              color: _currentLineStyle.color,
            ),
            onPressed: () {
              showDialog<Color>(
                context: context,
                builder: (BuildContext context) => ColorPicker(
                  color: _currentLineStyle.color,
                  onColorSelected: (Color color) {
                    setState(() {
                      _lineStyle = _currentLineStyle.copyWith(color: color);
                    });
                    updateIndicator();
                  },
                ),
              );
            },
          ),
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

  Widget _buildPinLabelsField() => Row(
        children: <Widget>[
          Text(
            ChartLocalization.of(context).labelPinLabels,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Switch(
            value: _currentPinLabels,
            onChanged: (bool value) {
              setState(() {
                _pinLabels = value;
              });
              updateIndicator();
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          ),
        ],
      );

  Widget _buildOverBoughtPriceField() => OscillatorLimit(
        label: ChartLocalization.of(context).labelOverBoughtPrice,
        value: _getCurrentOverBoughtPrice(),
        color: _currentOverboughtStyle.color,
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _overBoughtPrice = double.tryParse(text);
          } else {
            _overBoughtPrice = 0.8;
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

  Widget _buildOverSoldPriceField() => OscillatorLimit(
        label: ChartLocalization.of(context).labelOverSoldPrice,
        value: _getCurrentOverSoldPrice(),
        color: _currentOversoldStyle.color,
        onValueChanged: (String text) {
          if (text.isNotEmpty) {
            _overSoldPrice = double.tryParse(text);
          } else {
            _overSoldPrice = -0.8;
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

  int _getCurrentPeriod() =>
      _period ?? (widget.config as BOPIndicatorConfig).period;

  double _getCurrentOverBoughtPrice() =>
      _overBoughtPrice ??
      (widget.config as BOPIndicatorConfig)
          .oscillatorLinesConfig
          .overboughtValue;

  double _getCurrentOverSoldPrice() =>
      _overSoldPrice ??
      (widget.config as BOPIndicatorConfig).oscillatorLinesConfig.oversoldValue;

  LineStyle get _currentLineStyle =>
      _lineStyle ?? (widget.config as BOPIndicatorConfig).lineStyle;

  LineStyle get _currentOverboughtStyle =>
      _overboughtStyle ??
      (widget.config as BOPIndicatorConfig)
          .oscillatorLinesConfig
          .overboughtStyle;

  LineStyle get _currentOversoldStyle =>
      _oversoldStyle ??
      (widget.config as BOPIndicatorConfig).oscillatorLinesConfig.oversoldStyle;

  bool get _currentShowZones =>
      _showZones ?? (widget.config as BOPIndicatorConfig).showZones;

  bool get _currentPinLabels =>
      _pinLabels ?? (widget.config as BOPIndicatorConfig).pinLabels;
}

/// Color picker dialog
class ColorPicker extends StatelessWidget {
  /// Initializes
  const ColorPicker({
    required this.color,
    required this.onColorSelected,
    super.key,
  });

  /// Current color
  final Color color;

  /// Callback when color is selected
  final void Function(Color) onColorSelected;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPalette(
            color: color,
            onColorSelected: onColorSelected,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
}

/// Color palette widget
class ColorPalette extends StatelessWidget {
  /// Initializes
  const ColorPalette({
    required this.color,
    required this.onColorSelected,
    super.key,
  });

  /// Current color
  final Color color;

  /// Callback when color is selected
  final void Function(Color) onColorSelected;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[
          _buildColorButton(Colors.red),
          _buildColorButton(Colors.pink),
          _buildColorButton(Colors.purple),
          _buildColorButton(Colors.deepPurple),
          _buildColorButton(Colors.indigo),
          _buildColorButton(Colors.blue),
          _buildColorButton(Colors.lightBlue),
          _buildColorButton(Colors.cyan),
          _buildColorButton(Colors.teal),
          _buildColorButton(Colors.green),
          _buildColorButton(Colors.lightGreen),
          _buildColorButton(Colors.lime),
          _buildColorButton(Colors.yellow),
          _buildColorButton(Colors.amber),
          _buildColorButton(Colors.orange),
          _buildColorButton(Colors.deepOrange),
          _buildColorButton(Colors.brown),
          _buildColorButton(Colors.grey),
          _buildColorButton(Colors.blueGrey),
          _buildColorButton(Colors.black),
          _buildColorButton(Colors.white),
        ],
      );

  Widget _buildColorButton(Color color) => GestureDetector(
        onTap: () => onColorSelected(color),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(
              color: this.color == color ? Colors.blue : Colors.grey,
              width: this.color == color ? 2 : 1,
            ),
          ),
        ),
      );
}
